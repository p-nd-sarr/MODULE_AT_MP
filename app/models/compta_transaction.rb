class ComptaTransaction < ApplicationRecord
  self.primary_key = 'id'

  STATUT = {
    en_attente_validation: -1,
    en_cours: 0,
    paye: 1,
    marque_impaye: 2,
    impaye: 3,
    regularise: 4
  }.freeze

  enum statut: STATUT

  enum mode_paiement: MODE_PAIEMENT
  enum zone: ZONE

  belongs_to :dossier, polymorphic: true, optional: true
  belongs_to :ordre_paiement #, optional: true
  belongs_to :echeance_paiement, optional: true#, touch: true
  belongs_to :admin_region, :class_name => 'Admin::Region', foreign_key: :admin_region_id, optional: true
  belongs_to :admin_agence, :class_name => 'Admin::Agence', foreign_key: :admin_agence_id, optional: true

  before_validation :set_ordre_paiement, :set_date_comptable

  belongs_to :allocataire, foreign_key: :numero_allocataire, primary_key: :numero_allocataire, optional: true
  belongs_to :participant, :class_name => 'Psrm::Participant', foreign_key: :numero_allocataire, primary_key: :matric,
             optional: true

  after_commit :send_to_compta_task

  def send_to_compta_task
    return if send_to_compta? or not can_send_to_compta?
    GeneratePsrmTransactionJob.perform_later(self)
  end

  def generate_psrm_transaction
    return unless can_send_to_compta? #or send_to_compta?
    # return unless ordre_paiement.regularisation_pointage.nil?
    if echeance_paiement.nil?
      klass_compta_event = Psrm::ComptaEvent
      klass_compta_transaction = Psrm::ComptaTransaction
    else
      klass_compta_event = Psrm::ComptaEventLocal
      klass_compta_transaction = Psrm::ComptaTransactionLocal
    end

    nature_prestation = Admin::ComptaNaturePrestation.find_by(code: code_operation)
    branche_liq = if nature_prestation.ve?
                    'VE'
                  elsif nature_prestation.pf?
                    'PF'
                  elsif nature_prestation.at?
                    'AT'
                  else
                    nil
                  end

    begin
      if Rails.env.production? or Rails.env.staging?
        return if klass_compta_event.exists?(
          legal_entity_id: nature_prestation.ipres? ? 28277 : 26275,
          event_id: id,
        )

        klass_compta_event.create(
          # application_id: 100,
          legal_entity_id: nature_prestation.ipres? ? 28277 : 26275,
          entity_id: ordre_paiement.id,
          code_type_ligne_operation: code_operation,
          desc_ligne_paiement: description,
          montant_ligne: self.montant,

          event_id: id,
          creation_date: created_at,
          created_by: 1230,
          last_update_date: nil,
          last_updated_by: nil,
          last_update_login: nil,
        )

        if en_tete? and not klass_compta_transaction.exists?(legal_entity_id: nature_prestation.ipres? ? 28277 : 26275,
                                                             numero_ordre_paiement: ordre_paiement.numero)
          klass_compta_transaction.create(
            # application_id: 100,
            legal_entity_id: nature_prestation.ipres? ? 28277 : 26275,
            entity_id: ordre_paiement.id,
            code_type_evenement: code_classe_evenement, #echeance_paiement.nil? ? 'LIQUIDATION' : 'ECHEANCE',
            date_evenement: (date_comptable || created_at),
            montant_op: nil, #echeance_paiement.nil? ? self.montant : nil,
            security_id_int_1: admin_agence.try(:code_psrm) || code_agence_liquidation, # I_PE pour IPRES code agence de liquidation
            ledger_id: nature_prestation.ipres? ? 2081 : 2021,
            id_allocataire: numero_allocataire,
            nom_allocataire: nom,
            pnom_allocataire: prenom,
            adresse_allocataire: adresse,
            adresse_rue: allocataire.try(:adresse_rue).try(:strip) || participant.try(:addr).try(:strip),
            adrese_ville: allocataire.try(:adresse_ville).try(:strip) || participant.try(:addr).try(:strip),
            branche_liq: branche_liq,
            creation_date: created_at,
            created_by: 1230,
            last_update_date: nil,
            last_updated_by: nil,
            last_update_login: nil,
            pays: senegal? ? 'Sénégal' : 'Autres',
            region: admin_region.try(:designation) || allocataire.try(:adresse_ville),
            code_statut_transaction: 'U',
            code_processus_transaction: 'U',
            mode_de_paiement: mode_paiement_before_type_cast,
            code_banque: bank_id,
            code_agence: nil,
            numero_compte_alloc: numero_compte_allocataire,
            zone_de_paiement: zone_before_type_cast,
            code_agence_paiement: admin_agence.try(:code_psrm),
            code_caisse_paiement: allocataire.try(:code_caisse_paiement),
            numero_ordre_paiement: ordre_paiement.numero,
            desc_ord_paiement: description,
            nin: nin_allocataire,
            num_tel: telephone_allocataire,
            email: mail_allocataire,
            categ_allocataire: allocataire.try(:categorie_before_type_cast), #catégorie de l'allocataire
            num_echeance: ordre_paiement.num_echeance || echeance_paiement.try(:periode_debut).try(:strftime, '%m/%Y'),
            attribute1: est_attributaire? ? id_reel_allocataire : (allocataire.try(:ipres_ancien_matric) || numero_allocataire),

            attribute2: nom_reel_allocataire,
            attribute3: prenom_reel_allocataire,
            attribute4: if est_attributaire?
                          'ATTRIBUTAIRE'
                        else
                          par_subrogation? ? 'SUBROGATION' : nil
                        end,
            attribute9: allocataire.try(:regime_before_type_cast),
            attribute10: infos_paiement_id_bhs,
            attribute11: infos_paiement_id_ccp,
            attribute12: infos_paiement_libelle_ccp,
            attribute13: infos_paiement_succursale_cncas || (mise_a_disposition_bancaire? ? 1 : nil),
            # attribute14: allocataire.try(:adresse_ville),
            attribute15: Rails.env,
          )
        end
      end

      unless send_to_compta?
        # dépot pret
        if code_operation == 'I_ATL'
          dossier.est_verse = true
          dossier.save
        end

        # remboursement pret
        if code_operation == 'I_RAT'
          dossier.date_premier_prelevement ||= Date.today
          dossier.date_dernier_prelevement = Date.today
          dossier.montant_restant -= montant.abs
          dossier.save
        end

        # avis tiers
        if code_operation == 'I_OSP'
          dossier.montant_restant -= montant.abs
          dossier.save
        end

        self.send_to_compta = true
        self.send_to_compta_at = DateTime.now
        self.statut = :paye
        self.save
        o = ordre_paiement
        o.statut = :paye
        o.paye_le = self.send_to_compta_at
        o.save
      end
    rescue OCIError => e
      puts "=====> #{e}"
    end
  end

  def regenerate_psrm_entete
    return unless can_send_to_compta? #or send_to_compta?
    # return unless ordre_paiement.regularisation_pointage.nil?
    if echeance_paiement.nil?
      klass_compta_event = Psrm::ComptaEvent
      klass_compta_transaction = Psrm::ComptaTransaction
    else
      klass_compta_event = Psrm::ComptaEventLocal
      klass_compta_transaction = Psrm::ComptaTransactionLocal
    end

    nature_prestation = Admin::ComptaNaturePrestation.find_by(code: code_operation)
    branche_liq = if nature_prestation.ve?
                    'VE'
                  elsif nature_prestation.pf?
                    'PF'
                  elsif nature_prestation.at?
                    'AT'
                  else
                    nil
                  end

    begin
      if Rails.env.production? or Rails.env.staging?
        if en_tete? and not klass_compta_transaction.exists?(numero_ordre_paiement: ordre_paiement.numero)
          klass_compta_transaction.create(
            # application_id: 100,
            legal_entity_id: nature_prestation.ipres? ? 28277 : 26275,
            entity_id: ordre_paiement.id,
            code_type_evenement: code_classe_evenement, #echeance_paiement.nil? ? 'LIQUIDATION' : 'ECHEANCE',
            date_evenement: (date_comptable || created_at),
            montant_op: nil, #echeance_paiement.nil? ? self.montant : nil,
            security_id_int_1: admin_agence.try(:code_psrm) || code_agence_liquidation, # I_PE pour IPRES code agence de liquidation
            ledger_id: nature_prestation.ipres? ? 2081 : 2021,
            id_allocataire: numero_allocataire,
            nom_allocataire: nom,
            pnom_allocataire: prenom,
            adresse_allocataire: adresse,
            adresse_rue: allocataire.try(:adresse_rue).try(:strip) || participant.try(:addr).try(:strip),
            adrese_ville: allocataire.try(:adresse_ville).try(:strip) || participant.try(:addr).try(:strip),
            branche_liq: branche_liq,
            creation_date: created_at,
            created_by: 1230,
            last_update_date: nil,
            last_updated_by: nil,
            last_update_login: nil,
            pays: senegal? ? 'Sénégal' : 'Autres',
            region: admin_region.try(:designation) || allocataire.try(:adresse_ville),
            code_statut_transaction: 'U',
            code_processus_transaction: 'U',
            mode_de_paiement: mode_paiement_before_type_cast,
            code_banque: bank_id,
            code_agence: nil,
            numero_compte_alloc: numero_compte_allocataire,
            zone_de_paiement: zone_before_type_cast,
            code_agence_paiement: admin_agence.try(:code_psrm),
            code_caisse_paiement: allocataire.try(:code_caisse_paiement),
            numero_ordre_paiement: ordre_paiement.numero,
            desc_ord_paiement: description,
            nin: nin_allocataire,
            num_tel: telephone_allocataire,
            email: mail_allocataire,
            categ_allocataire: allocataire.try(:categorie_before_type_cast), #catégorie de l'allocataire
            num_echeance: ordre_paiement.num_echeance || echeance_paiement.try(:periode_debut).try(:strftime, '%m/%Y'),
            attribute1: est_attributaire? ? id_reel_allocataire : (allocataire.try(:ipres_ancien_matric) || numero_allocataire),

            attribute2: nom_reel_allocataire,
            attribute3: prenom_reel_allocataire,
            attribute4: if est_attributaire?
                          'ATTRIBUTAIRE'
                        else
                          par_subrogation? ? 'SUBROGATION' : nil
                        end,
            attribute9: allocataire.try(:regime_before_type_cast),
            attribute10: infos_paiement_id_bhs,
            attribute11: infos_paiement_id_ccp,
            attribute12: infos_paiement_libelle_ccp,
            attribute13: infos_paiement_succursale_cncas || (mise_a_disposition_bancaire? ? 1 : nil),
            # attribute14: allocataire.try(:adresse_ville),
            attribute15: Rails.env,
          )
        end
      end
    rescue OCIError => e
      puts "=====> #{e}"
    end
  end

  private

  def set_date_comptable
    if date_comptable.nil?
      self.date_comptable = DateTime.now
    end
  end

  def set_ordre_paiement
    if ordre_paiement_id.nil?
      self.ordre_paiement = OrdrePaiement.create(dossier: self.dossier,
                                                 numero_allocataire: self.numero_allocataire)
    end
  end
end
