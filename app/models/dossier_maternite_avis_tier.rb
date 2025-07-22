class DossierMaterniteAvisTier < ApplicationRecord

    ETAT = {
        creation: 1,
        soumis: 2,
        valide: 3
      }.freeze
    
    TYPE_AVIS = {
        moins_percu: 2,
        trop_percu: 1
    }.freeze
      
    STATUS = {
        paye: 1,
        non_paye: 2
    }.freeze

    TYPE_MOTIF = {
      salaire_reference_errone: 1,
      nombre_jours_errone: 2
    }.freeze
    
    enum type_avis: TYPE_AVIS
    enum etat: ETAT
    enum status: STATUS
    enum type_motif: TYPE_MOTIF
    
    belongs_to :ajoute_par, class_name: 'User', foreign_key: :ajouter_par_id, optional: true
    belongs_to :soumis_par, class_name: 'User', foreign_key: :soumis_par_id, optional: true
    belongs_to :valide_par, class_name: 'User', foreign_key: :valider_par_id, optional: true
    belongs_to :retourne_par, class_name: 'User', foreign_key: :retourner_par_id, optional: true
    belongs_to :traite_par, class_name: 'User', foreign_key: :traite_par_id, optional: true
    belongs_to :dossier_maternite, foreign_key: :dossier_maternite_id
    
    has_many :ligne_icm_avis_tiers_transactions, foreign_key: :dossier_maternite_avis_tiers_id
    has_many :compta_transactions, through: :ordre_paiements
    
    validate :validate_motif_conditions
    validate :validate_payment_conditions

    before_save :calculate_montant_avis

    def total_jours_payes
      dossier_maternite.indemnite_conges_maternites.where(paiement: true).sum(:nbre_jr_payes)
    end

    def total_jours_indemnises
      dossier_maternite.indemnite_conges_maternites.sum(:nbre_jr_payes)
    end

    def calculate_montant_avis
      tranches = dossier_maternite.indemnite_conges_maternites
      
      if salaire_reference_errone?
        ecart_salaire = sal_ref_a_considere.to_f - dossier_maternite.salaire_reference.to_f
        
        if moins_percu?
          self.montant_avis = (ecart_salaire / 30 * total_jours_payes.to_i).round
        elsif trop_percu?
          paid_tranches = tranches.where(paiement: true).order(:tranche_paiement)

          total_days = 0
          self.montant_avis = 0

          paid_tranches.each do |tranche|
            total_days += tranche.nbre_jr_payes.to_i
            deduction = (-ecart_salaire / 30 * total_days).round
            self.montant_avis = deduction
          end
          dossier_maternite.update_montant_salaire(sal_ref_a_considere.to_f)
        end
      elsif nombre_jours_errone?
        if moins_percu?
          self.montant_avis = ((dossier_maternite.salaire_reference.to_f / 30) * 
                              (nbre_jours_a_indemnise.to_i - total_jours_payes.to_i)).round
        elsif trop_percu?
          ecart_jours = total_jours_indemnises.to_i - nbre_jours_a_indemnise.to_i
          self.montant_avis = ((dossier_maternite.salaire_reference.to_f / 30) * ecart_jours).round
        end
      end
    end

    def validate_payment_conditions
      tranches = dossier_maternite.indemnite_conges_maternites
      has_prolongation = tranches.exists?(prolongation: true)

      if trop_percu?
        if nombre_jours_errone?
          # Pour un trop perçu avec erreur de nombre de jours, on vérifie toutes les tranches
          mandatory_tranches_paid = tranches.where(paiement: true)
                                          .where(tranche_paiement: [1, 2, 3])
                                          .count == 3
          prolongation_condition = !has_prolongation || 
                                 (has_prolongation && tranches.where(tranche_paiement: 4).exists?)
          
          unless mandatory_tranches_paid && prolongation_condition
            errors.add(:base, "Veuillez ajouter l'attestation de reprise pour initier un trop perçu consécutif à une erreur sur le nombre de jours à indemninser")
          end
        else
          # Pour un trop perçu avec erreur de salaire, on garde la logique de la première tranche
          paid_first_tranches = tranches.where(paiement: true)
                                      .where(tranche_paiement: [1])
                                      .count
          if paid_first_tranches < 1
            errors.add(:base, "Un trop perçu ne peut être créé qu'après le paiement de la première tranche")
          end
        end
      elsif moins_percu?
        mandatory_tranches_paid = tranches.where(paiement: true)
                                        .where(tranche_paiement: [1, 2, 3])
                                        .count == 3
        prolongation_condition = !has_prolongation || 
                               (has_prolongation && tranches.where(tranche_paiement: 4, paiement: true).exists?)
        
        unless mandatory_tranches_paid && prolongation_condition
          errors.add(:base, "Un moins perçu ne peut être créé qu'après le paiement de toutes les tranches")
        end
      end
    end

    def validate_motif_conditions
      if salaire_reference_errone?
          if moins_percu?
              if sal_ref_a_considere.to_f <= dossier_maternite.salaire_reference.to_f
                  errors.add(:salaire_ref_à_considerer, "doit être supérieur au salaire de référence initial")
              end
          elsif trop_percu?
              if sal_ref_a_considere.to_f >= dossier_maternite.salaire_reference.to_f
                  errors.add(:salaire_ref_à_considerer, "doit être inférieur au salaire de référence initial")
              end
          end
      elsif nombre_jours_errone?
          if moins_percu?
              if nbre_jours_a_indemnise.to_i <= total_jours_payes.to_i
                  errors.add(:nombre_jours_à_indemniser, "doit être supérieur au nombre de jours indemnisés")
              end
          elsif trop_percu?
              if nbre_jours_a_indemnise.to_i >= total_jours_indemnises.to_i
                  errors.add(:nombre_jours_à_indemniser, "doit être inférieur au nombre de jours indemnisés")
              end
          end
      end
    end
    
    def get_amount_paid
      ligne_icm_avis_tiers_transactions.sum(:montant_paye)
    end
    
    def remaining_amount
      montant_avis - get_amount_paid
    end
    
    def attente_paiement?
      valide? and non_paye? and moins_percu?
    end
    
    def valider_paiement(user)
      return if montant_avis.nil?
    
      self.traite_par = User.current
      self.traite_le = Date.today
      op = OrdrePaiement.create(dossier: dossier_maternite, numero_allocataire: dossier_maternite.num_affiliation)
      amount = remaining_amount

      payment_mode = amount < 100_000 ? :caisse_css : :cheque
      cb = nil
      nc = nil
     
      if valide? and traite_par.comptable? and not ComptaTransaction.exists?(dossier: self) and not LigneIcmAvisTiersTransaction.exists?(ordre_paiement: op)
        li = LigneIcmAvisTiersTransaction.new
        li.dossier_maternite_avis_tier = self
        li.ordre_paiement = op
        li.montant = remaining_amount
        li.montant_paye = remaining_amount
        li.ajoute_par = User.current
        puts 'error', li.errors.full_messages unless li.save
    
        ComptaTransaction.create(
          en_tete: true,
          dossier: self,
          ordre_paiement: op,
          code_operation: 'PF_IJCM_AVIS',
          code_classe_evenement: 'LIQUIDATION',
          code_agence_liquidation: traite_par.agence.try(:code_psrm) || 'C_SG', # à définir
          est_attributaire: dossier_maternite.attributaire?,
          par_subrogation: dossier_maternite.subrogation?,
          numero_allocataire: if dossier_maternite.subrogation?
                                dossier_maternite.participant.psrm_employeur.fhnum
                              else
                                dossier_maternite.attributaire? ? dossier_maternite.nin_attributaire : dossier_maternite.num_dossier
                              end,
          nom: if dossier_maternite.subrogation?
                 dossier_maternite.participant.psrm_employeur.fhrsoc
               else
                 dossier_maternite.attributaire? ? dossier_maternite.nom_attributaire : dossier_maternite.nom
               end,
          prenom: dossier_maternite.attributaire? ? dossier_maternite.prenom_attributaire : dossier_maternite.prenom,
          adresse: dossier_maternite.adresse_domicile,
          mode_paiement: payment_mode,
          code_banque_allocataire: cb,
          numero_compte_allocataire: nc,
          bank_id: dossier_maternite.bank_id,
          bank_branch_id: dossier_maternite.bank_branch_id,
          date_debut_periode: nil,
          date_fin_periode: nil,
          montant: amount,
          code_devise: 'XOF',
          description: "Avis à tiers. Numéro Dossier : #{dossier_maternite.num_dossier}",
          id_reel_allocataire: dossier_maternite.attributaire? ? dossier_maternite.num_dossier : nil,
          nom_reel_allocataire: dossier_maternite.attributaire? ? dossier_maternite.nom : nil,
          prenom_reel_allocataire: dossier_maternite.attributaire? ? dossier_maternite.prenom : nil,
          statut: :en_cours,
          )
    
          self.status = DossierMaterniteAvisTier.statuses['paye']
          self.save
        end
    
        true
    end
    
end
