class EcheancePaiement < ApplicationRecord
  include WorkflowActiverecord

  InvalidTransitionError = Class.new(StandardError)
  workflow_column :workflow_state

  workflow do
    state :creation do
      event :est_valider_section, transition_to: :valider_chef_section
    end

    state :valider_chef_section do
      event :section_valider, transition_to: :valider_chef_service
    end

    state :valider_chef_service do
      event :service_valider, transition_to: :valider_directeur
      event :est_rejete, transition_to: :rejeter
    end

    state :rejeter
    state :valider_directeur

    on_transition do |from, to, triggering_event, *event_args|
      puts "#{from} -> #{to}"
    end

    #  use after transition for historisation
    after_transition do
      puts " => traite par : #{self.traite_par} "
    end

    on_error do |error, from, to, event, *args|
      puts "Exception(#error.class) on #{from} -> #{to}"
    end
  end

  PERIODE = {
    mensuelle: 1,
    bimestrielle: 2,
    trimestrielle: 3,
    immediate: 4
  }.freeze

  enum periode: PERIODE

  belongs_to :traite_par, class_name: 'User', foreign_key: :traite_par_id, optional: true
  belongs_to :valider_par, class_name: 'User', foreign_key: :validation_par_id, optional: true

  belongs_to :instruit_par, class_name: 'User', foreign_key: :instruit_par, optional: true
  belongs_to :liquider_par, class_name: 'User', foreign_key: :liquider_par, optional: true
  belongs_to :valider_chef_section_par, class_name: 'User', foreign_key: :valider_chef_section_par, optional: true
  belongs_to :valider_service_par, class_name: 'User', foreign_key: :valider_service_par, optional: true

  has_many :paiement_allocataires
  has_many :compta_transactions
  has_many :ordre_paiements
  has_many :allocataires, -> { distinct }, through: :compta_transactions

  after_commit :generate_paiements, on: :create

  before_save :validation_instruction!
  before_create :set_periode_variation

  def periode_debut
    return Date.new(annee, numero_periode, 1).beginning_of_month if mensuelle?
    return Date.new(annee, numero_periode * 2, 1).beginning_of_bimester if bimestrielle?
    Date.new(annee, numero_periode * 3, 1).beginning_of_quarter if trimestrielle?
  end

  def periode_fin
    return Date.new(annee, numero_periode, 1).end_of_month if mensuelle?
    return Date.new(annee, numero_periode * 2, 1).end_of_bimester if bimestrielle?
    Date.new(annee, numero_periode * 3, 1).end_of_quarter if trimestrielle?
  end

  def validation_instruction!
    if creation? and validation_liquidation? and validation_instruction?
      est_valider_section!
    end
  end

  def montant_total
    compta_transactions.sum(:montant)
  end

  def nombre_allocataires
    allocataires.distinct.count(:numero_allocataire)
  end

  def generate_paiements
    return if est_repris?
    Admin::BaremePension.set_valeur_point_mensuelle_rg
    Admin::BaremePension.set_valeur_point_mensuelle_rc
    valeur_point_mensuelle_rg = Admin::BaremePension.get_valeur_point_mensuelle_rg
    valeur_point_mensuelle_rc = Admin::BaremePension.get_valeur_point_mensuelle_rc
    OrdrePaiement.set_last_number(Date.today.strftime('%Y%m%d'))
    OrdrePaiement.set_last_number(Date.tomorrow.strftime('%Y%m%d'))

    puts "==> #{DateTime.now} suppression du contenu des tables xxipres_css_op_det et xxipres_css_op"
    ActiveRecord::Base.connection.execute("truncate xxipres_css_op_det ; truncate xxipres_css_op_ent")
    puts "<== #{DateTime.now} fin suppression du contenu des tables xxipres_css_op_det et xxipres_css_op"

    puts "==> #{DateTime.now} mise a jour date_sortie_majoration"
    ActiveRecord::Base.connection.execute("UPDATE allocataires SET
        date_sortie_majoration = greatest(date_fin_enfant1, date_fin_enfant2, date_fin_enfant3)
      WHERE versement_unique = 'f' AND etat = 1 AND categorie <> 2")
    puts "<== #{DateTime.now} fin mise a jour date_sortie_majoration"

    puts "==> #{DateTime.now} mise a jour pension veuves/orphelins"
    pension_minimale = 0
    ActiveRecord::Base.connection.execute("UPDATE allocataires SET
        montant_brut_rg = points_servis_rg * #{valeur_point_mensuelle_rg},
        montant_brut_rc = points_servis_rc * #{valeur_point_mensuelle_rc},
        montant_subvention = #{pension_minimale} - least(#{pension_minimale}, points_servis_rg * #{valeur_point_mensuelle_rg} + points_servis_rc * #{valeur_point_mensuelle_rc}),
        montant_net = greatest(#{pension_minimale}, points_servis_rg * #{valeur_point_mensuelle_rg} + points_servis_rc * #{valeur_point_mensuelle_rc})
      WHERE versement_unique = 'f' AND etat = 1 AND categorie IN (6, 8)")
    puts "<==  #{DateTime.now} fin mise a jour pension veuves/orphelins"

    puts "==> #{DateTime.now} mise a jour pourcentage_majoration retraite"
    ActiveRecord::Base.connection.execute("UPDATE allocataires SET
        pourcentage_majoration = 5.0*(CASE WHEN date_fin_enfant1 >= '#{periode_debut}' THEN 1 ELSE 0 END + CASE WHEN date_fin_enfant2 >= '#{periode_debut}' THEN 1 ELSE 0 END + CASE WHEN date_fin_enfant3 >= '#{periode_debut}' THEN 1 ELSE 0 END),
        pourcentage_majoration_rg = 5.0*(CASE WHEN date_fin_enfant1 >= '#{periode_debut}' THEN 1 ELSE 0 END + CASE WHEN date_fin_enfant2 >= '#{periode_debut}' THEN 1 ELSE 0 END + CASE WHEN date_fin_enfant3 >= '#{periode_debut}' THEN 1 ELSE 0 END),
        pourcentage_majoration_rc = 5.0*(CASE WHEN date_fin_enfant1 >= '#{periode_debut}' THEN 1 ELSE 0 END + CASE WHEN date_fin_enfant2 >= '#{periode_debut}' THEN 1 ELSE 0 END + CASE WHEN date_fin_enfant3 >= '#{periode_debut}' THEN 1 ELSE 0 END)
      WHERE versement_unique = 'f' AND etat = 1 AND categorie = 1")
    puts "<==  #{DateTime.now} fin mise a jour pourcentage_majoration retraite"

    puts "==> #{DateTime.now} mise a jour pension retraite"
    pension_minimale = 35_000
    ActiveRecord::Base.connection.execute("UPDATE allocataires SET
        point_majoration_rg = round(points_base_rg * pourcentage_majoration_rg / 100.0),
        point_majoration_rc = round(points_base_rc * pourcentage_majoration_rc / 100.0),
        point_majoration = round(points_base_rg * pourcentage_majoration_rg / 100.0) + round(points_base_rc * pourcentage_majoration_rc / 100.0),
        points_servis_rg = ceil(points_base_rg + round(points_base_rg * pourcentage_majoration_rg / 100.0)),
        points_servis_rc = ceil(points_base_rc + round(points_base_rc * pourcentage_majoration_rc / 100.0)),
        points_servis = ceil(points_base_rg + round(points_base_rg * pourcentage_majoration_rg / 100.0)) + ceil(points_base_rc + round(points_base_rc * pourcentage_majoration_rc / 100.0)),
        montant_brut_rg = points_servis_rg * #{valeur_point_mensuelle_rg},
        montant_brut_rc = points_servis_rc * #{valeur_point_mensuelle_rc},
        montant_subvention = #{pension_minimale} - least(#{pension_minimale}, points_base_rc * #{valeur_point_mensuelle_rc} + points_base_rg * #{valeur_point_mensuelle_rg}),
        montant_net = points_servis_rg * #{valeur_point_mensuelle_rg} + points_servis_rc * #{valeur_point_mensuelle_rc} + #{pension_minimale} - least(#{pension_minimale}, points_base_rc * #{valeur_point_mensuelle_rc} + points_base_rg * #{valeur_point_mensuelle_rg})
      WHERE versement_unique = 'f' AND etat = 1 AND categorie = 1")
    puts "<==  #{DateTime.now} fin mise a jour pension retraite"

    allocataires = Allocataire.versement_mensuels.actif.where.not(categorie: :coordination) #.sample(1_000)
    nb = allocataires.count
    i = 0
    allocataires.each do |allocataire|
      puts "#{(100.0 * i / nb).ceil(2)} %"
      GeneratePaiementAllocataireJob.perform_later(self, allocataire)
      i += 1
      puts "#{(100.0 * i / nb).ceil(2)} %"
    end

    # cotisation association allocataire
    Admin::AssociationAllocataire.all.each { |association|
      nb_allocataires = association.allocataires.versement_mensuels.actif.where.not(categorie: :coordination).count
      ComptaTransaction.create(
        echeance_paiement: self,
        dossier: association,
        code_operation: 'I_RETASSRET',
        code_classe_evenement: 'ECHEANCE',
        code_agence_liquidation: 'I_SG',
        numero_allocataire: association.name,
        date_debut_periode: nil,
        date_fin_periode: nil,
        montant: 100 * nb_allocataires,
        code_devise: 'XOF',
        statut: :en_attente_validation,
        description: "Cotisation association #{association.name}",
        can_send_to_compta: false,
      )
    }
  end

  # @param [Allocataire] allocataire
  def generate_paiement_allocataire(allocataire)
    # if allocataire.retraite? or allocataire.orphelin? or allocataire.veuve?
    #   allocataire.set_date_sortie_majoration
    #   allocataire.recalculer_allocation(periode_debut)
    # end

    op = OrdrePaiement.create(echeance_paiement: self,
                              dossier: allocataire,
                              numero_allocataire: allocataire.numero_allocataire,
                              statut: :en_attente_validation)

    # cotisation association allocataire
    unless allocataire.admin_association_allocataire.nil?
      ComptaTransaction.create(
        en_tete: false,
        echeance_paiement: self,
        ordre_paiement: op,
        dossier: allocataire,
        code_operation: 'I_RETASSRET',
        code_classe_evenement: 'ECHEANCE',
        code_agence_liquidation: 'I_SG',
        numero_allocataire: allocataire.numero_allocataire,
        nom: allocataire.nom,
        prenom: allocataire.prenom,
        adresse: allocataire.adresse_rue,
        mode_paiement: allocataire.mode_paiement,
        code_banque_allocataire: allocataire.compte_bancaire_code_banque,
        numero_compte_allocataire: allocataire.rib,
        bank_id: allocataire.bank_id,
        bank_branch_id: allocataire.bank_branch_id,
        date_debut_periode: nil,
        date_fin_periode: nil,
        montant: -100,
        code_devise: 'XOF',
        statut: :en_attente_validation,
        description: "Cotisation association #{allocataire.admin_association_allocataire.name}",
        admin_agence: allocataire.admin_agence,
        nin_allocataire: allocataire.numero_identification_nationale,
        telephone_allocataire: allocataire.telephone,
        mail_allocataire: allocataire.email,
        can_send_to_compta: false,
        date_comptable: periode_debut,
        admin_region: allocataire.admin_region,
        zone: allocataire.zone,
        infos_paiement_id_bhs: allocataire.infos_paiement_id_bhs,
        infos_paiement_id_ccp: allocataire.infos_paiement_id_ccp,
        infos_paiement_libelle_ccp: allocataire.infos_paiement_libelle_ccp,
        infos_paiement_succursale_cncas: allocataire.infos_paiement_succursale_cncas,
        )
    end

    # remboursement allocataire
    allocataire.pret_allocataire_lignes.a_rembourser.each { |pret|
      ComptaTransaction.create(
        en_tete: false,
        echeance_paiement: self,
        ordre_paiement: op,
        dossier: pret,
        code_operation: 'I_RAT',
        code_classe_evenement: 'ECHEANCE',
        code_agence_liquidation: 'I_SG',
        numero_allocataire: allocataire.numero_allocataire,
        nom: allocataire.nom,
        prenom: allocataire.prenom,
        adresse: allocataire.adresse_rue,
        mode_paiement: allocataire.mode_paiement,
        code_banque_allocataire: allocataire.compte_bancaire_code_banque,
        numero_compte_allocataire: allocataire.rib,
        bank_id: allocataire.bank_id,
        bank_branch_id: allocataire.bank_branch_id,
        date_debut_periode: nil,
        date_fin_periode: nil,
        montant: -pret.montant_retenue,
        code_devise: 'XOF',
        statut: :en_attente_validation,
        description: "Remboursement prêt #{pret.pret_allocataire.try(:type_pret)}",
        admin_agence: allocataire.admin_agence,
        nin_allocataire: allocataire.numero_identification_nationale,
        telephone_allocataire: allocataire.telephone,
        mail_allocataire: allocataire.email,
        can_send_to_compta: false,
        date_comptable: periode_debut,
        admin_region: allocataire.admin_region,
        zone: allocataire.zone,
        infos_paiement_id_bhs: allocataire.infos_paiement_id_bhs,
        infos_paiement_id_ccp: allocataire.infos_paiement_id_ccp,
        infos_paiement_libelle_ccp: allocataire.infos_paiement_libelle_ccp,
        infos_paiement_succursale_cncas: allocataire.infos_paiement_succursale_cncas,
        )
    }

    # avis tiers
    allocataire.avis_tiers.validation_directeur.a_rembourser.each { |at|
      ComptaTransaction.create(
        en_tete: false,
        echeance_paiement: self,
        ordre_paiement: op,
        dossier: at,
        code_operation: 'I_OSP',
        code_classe_evenement: 'ECHEANCE',
        code_agence_liquidation: 'I_SG',
        numero_allocataire: allocataire.numero_allocataire,
        nom: allocataire.nom,
        prenom: allocataire.prenom,
        adresse: allocataire.adresse_rue,
        mode_paiement: allocataire.mode_paiement,
        code_banque_allocataire: allocataire.compte_bancaire_code_banque,
        numero_compte_allocataire: allocataire.rib,
        bank_id: allocataire.bank_id,
        bank_branch_id: allocataire.bank_branch_id,
        date_debut_periode: nil,
        date_fin_periode: nil,
        montant: -at.montant_retenue,
        code_devise: 'XOF',
        statut: :en_attente_validation,
        description: "Avis tier #{at.try(:type_operation)}",
        admin_agence: allocataire.admin_agence,
        nin_allocataire: allocataire.numero_identification_nationale,
        telephone_allocataire: allocataire.telephone,
        mail_allocataire: allocataire.email,
        can_send_to_compta: false,
        date_comptable: periode_debut,
        admin_region: allocataire.admin_region,
        zone: allocataire.zone,
        infos_paiement_id_bhs: allocataire.infos_paiement_id_bhs,
        infos_paiement_id_ccp: allocataire.infos_paiement_id_ccp,
        infos_paiement_libelle_ccp: allocataire.infos_paiement_libelle_ccp,
        infos_paiement_succursale_cncas: allocataire.infos_paiement_succursale_cncas,
        )
    }

    # pension alimentaire
    Allocataire.pension_alimentaire.versement_mensuels.actif.
      where(numero_allocataire_donneur: [allocataire.numero_allocataire, allocataire.ipres_ancien_matric].compact).each do |pa|
      ComptaTransaction.create(
        en_tete: false,
        echeance_paiement: self,
        ordre_paiement: op,
        dossier: allocataire,
        code_operation: 'I_RPA',
        code_classe_evenement: 'ECHEANCE',
        code_agence_liquidation: 'I_SG',
        numero_allocataire: allocataire.numero_allocataire,
        nom: allocataire.nom,
        prenom: allocataire.prenom,
        adresse: allocataire.adresse_rue,
        mode_paiement: allocataire.mode_paiement,
        code_banque_allocataire: allocataire.compte_bancaire_code_banque,
        numero_compte_allocataire: allocataire.rib,
        bank_id: allocataire.bank_id,
        bank_branch_id: allocataire.bank_branch_id,
        date_debut_periode: nil,
        date_fin_periode: nil,
        montant: -pa.montant_net,
        code_devise: 'XOF',
        statut: :en_attente_validation,
        description: "Pension alimentaire pour #{pa.full_name} (#{pa.numero_allocataire})",
        admin_agence: allocataire.admin_agence,
        nin_allocataire: allocataire.numero_identification_nationale,
        telephone_allocataire: allocataire.telephone,
        mail_allocataire: allocataire.email,
        can_send_to_compta: false,
        date_comptable: periode_debut,
        admin_region: allocataire.admin_region,
        zone: allocataire.zone,
        infos_paiement_id_bhs: allocataire.infos_paiement_id_bhs,
        infos_paiement_id_ccp: allocataire.infos_paiement_id_ccp,
        infos_paiement_libelle_ccp: allocataire.infos_paiement_libelle_ccp,
        infos_paiement_succursale_cncas: allocataire.infos_paiement_succursale_cncas,
        )
    end

    # pret allocataire
    allocataire.pret_allocataire_lignes.non_verses.each { |pret|
      ComptaTransaction.create(
        en_tete: false,
        echeance_paiement: self,
        ordre_paiement: op,
        dossier: pret,
        code_operation: 'I_ATL',
        code_classe_evenement: 'ECHEANCE',
        code_agence_liquidation: 'I_SG',
        numero_allocataire: allocataire.numero_allocataire,
        nom: allocataire.nom,
        prenom: allocataire.prenom,
        adresse: allocataire.adresse_rue,
        mode_paiement: allocataire.mode_paiement,
        code_banque_allocataire: allocataire.compte_bancaire_code_banque,
        numero_compte_allocataire: allocataire.rib,
        bank_id: allocataire.bank_id,
        bank_branch_id: allocataire.bank_branch_id,
        date_debut_periode: nil,
        date_fin_periode: nil,
        montant: pret.montant,
        code_devise: 'XOF',
        statut: :en_attente_validation,
        description: "Prêt #{pret.pret_allocataire.try(:type_pret)}",
        admin_agence: allocataire.admin_agence,
        nin_allocataire: allocataire.numero_identification_nationale,
        telephone_allocataire: allocataire.telephone,
        mail_allocataire: allocataire.email,
        can_send_to_compta: false,
        date_comptable: periode_debut,
        admin_region: allocataire.admin_region,
        zone: allocataire.zone,
        infos_paiement_id_bhs: allocataire.infos_paiement_id_bhs,
        infos_paiement_id_ccp: allocataire.infos_paiement_id_ccp,
        infos_paiement_libelle_ccp: allocataire.infos_paiement_libelle_ccp,
        infos_paiement_succursale_cncas: allocataire.infos_paiement_succursale_cncas,
      )
    }

    unless allocataire.rappel_augmentation_envoye?
      montant_rappel = allocataire.diff_montant_net_m1 + allocataire.diff_montant_net_m2

      if montant_rappel > 0
        ComptaTransaction.create(
          en_tete: false,
          echeance_paiement: self,
          ordre_paiement: op,
          dossier: allocataire,
          code_operation: 'I_BRAC',
          code_classe_evenement: 'ECHEANCE',
          code_agence_liquidation: 'I_SG',
          numero_allocataire: allocataire.numero_allocataire,
          nom: allocataire.nom,
          prenom: allocataire.prenom,
          adresse: allocataire.adresse_rue,
          mode_paiement: allocataire.mode_paiement,
          code_banque_allocataire: allocataire.compte_bancaire_code_banque,
          numero_compte_allocataire: allocataire.rib,
          bank_id: allocataire.bank_id,
          bank_branch_id: allocataire.bank_branch_id,
          date_debut_periode: nil,
          date_fin_periode: nil,
          montant: montant_rappel,
          code_devise: 'XOF',
          statut: :en_attente_validation,
          description: "Rappel jan. et fev. 2023 : augmentation 10% => #{allocataire.diff_montant_net_m1} + #{allocataire.diff_montant_net_m2}",
          admin_agence: allocataire.admin_agence,
          nin_allocataire: allocataire.numero_identification_nationale,
          telephone_allocataire: allocataire.telephone,
          mail_allocataire: allocataire.email,
          can_send_to_compta: false,
          date_comptable: periode_debut,
          admin_region: allocataire.admin_region,
          zone: allocataire.zone,

          infos_paiement_id_bhs: allocataire.infos_paiement_id_bhs,
          infos_paiement_id_ccp: allocataire.infos_paiement_id_ccp,
          infos_paiement_libelle_ccp: allocataire.infos_paiement_libelle_ccp,
          infos_paiement_succursale_cncas: allocataire.infos_paiement_succursale_cncas,
          )
        allocataire.update_columns(rappel_augmentation_envoye: true)
      end
    end

    # pension mensuelle
    ComptaTransaction.create(
      echeance_paiement: self,
      ordre_paiement: op,
      dossier: allocataire,
      code_operation: 'I_EAC',
      code_classe_evenement: 'ECHEANCE',
      code_agence_liquidation: 'I_SG',
      numero_allocataire: allocataire.numero_allocataire,
      nom: allocataire.nom,
      prenom: allocataire.prenom,
      adresse: allocataire.adresse_rue,
      mode_paiement: allocataire.mode_paiement,
      code_banque_allocataire: allocataire.compte_bancaire_code_banque,
      numero_compte_allocataire: allocataire.rib,
      bank_id: allocataire.bank_id,
      bank_branch_id: allocataire.bank_branch_id,
      date_debut_periode: nil,
      date_fin_periode: nil,
      montant: allocataire.montant_net,
      montant_subvention: allocataire.montant_subvention,
      code_devise: 'XOF',
      statut: :en_attente_validation,
      description: "Versement mensuel",
      admin_agence: allocataire.admin_agence,
      nin_allocataire: allocataire.numero_identification_nationale,
      telephone_allocataire: allocataire.telephone,
      mail_allocataire: allocataire.email,
      can_send_to_compta: false,
      date_comptable: periode_debut,
      admin_region: allocataire.admin_region,
      zone: allocataire.zone,

      infos_paiement_id_bhs: allocataire.infos_paiement_id_bhs,
      infos_paiement_id_ccp: allocataire.infos_paiement_id_ccp,
      infos_paiement_libelle_ccp: allocataire.infos_paiement_libelle_ccp,
      infos_paiement_succursale_cncas: allocataire.infos_paiement_succursale_cncas,
    )
  end

  def generate_paiements_compta
    return if est_repris?
    return unless valider_directeur?

    transactions = compta_transactions.where(send_to_compta: false) #.includes(:ordre_paiement)

    nb = transactions.count
    i = 0
    transactions.each do |compta_transaction|
      puts "#{(100.0 * i / nb).ceil(2)} %"
      compta_transaction.can_send_to_compta = true
      # compta_transaction.statut = :en_cours
      compta_transaction.save
      # compta_transaction.ordre_paiement.en_cours!
      i += 1
      puts "#{(100.0 * i / nb).ceil(2)} %"
    end

    self.send_to_compta = true
    self.save
  end

  def set_periode_variation
    self.periode_variation_debut = EcheancePaiement.maximum(:periode_variation_fin) || periode_debut - 1.month if periode_variation_debut.nil?
    self.periode_variation_fin = created_at || DateTime.now if periode_variation_fin.nil?
  end

  def generate_caisse_paiement
    ordre_paiements = OrdrePaiement.joins(:compta_transactions).where(echeance_paiement_id: self.id, send_to_caisse_paiement: false, compta_transactions: {mode_paiement: :paiement_a_domicile}).includes(:compta_transactions)
    i = 0
    total = ordre_paiements.size
    ordre_paiements.each { |o|
      o.generate_caisse_paiement
      i += 1
      puts "#{i}/#{total}"
    }
    true
  end
end
