class AllocataireCnav < ApplicationRecord

  ETAT = {
      creation: 1,
      soumis: 2,
      traitement_en_cours: 3,
      valide: 4,
      rejete: 5,
      valide_liquidation: 6,
      rejete_liquidation: 7,
      valide_inspection: 8,
      rejete_inspection: 9
  }.freeze
  enum etat: ETAT

  DELTA = {
      nouveau: 1,
      ancien: 2,
      supprime: 3
  }.freeze
  enum delta: DELTA

  MODE_PAIEMENT = {
    mandant_postal: 1,
    virement: 2,
    # caisse_ipres: 4,
    # post_finance: 5,
    mise_a_disposition_bancaire: 6,
    carte_prepaye: 8,
    paiement_a_domicile: 9,
    orange_money: 12,
    wave: 13,
    paiement_hors_convention: 14,
    autres: 100
  }.freeze
  # enum mode_paiement: MODE_PAIEMENT_CAISSE_IPRES
  enum mode_paiement: MODE_PAIEMENT

  belongs_to :dossier_cnav, class_name: 'DossierCnav', foreign_key: :dossier_cnav_id
  belongs_to :user, optional: true

  belongs_to :admin_region, :class_name => 'Admin::Region', foreign_key: :admin_region_id, optional: true
  belongs_to :admin_banque, :class_name => 'Admin::Banque', foreign_key: :admin_banque_id, optional: true
  belongs_to :traite_par, class_name: 'User', foreign_key: :traite_par_id, optional: true
  belongs_to :ajoute_par, class_name: 'User', foreign_key: :ajoute_par_id
  belongs_to :valider_liq_par, class_name: 'User', foreign_key: :valider_liq_par_id, optional: true
  belongs_to :valider_insp_par, class_name: 'User', foreign_key: :valider_insp_par_id, optional: true
  #belongs_to :ordre_paiement, optional: true

  #validates :numero, uniqueness: true

  scope :est_liquide, -> { where(etat: :soumis) }
  scope :non_paye, -> { where(paiement: false) }
  scope :paye, -> { where(paiement: true) }
  scope :en_attente, -> { where(etat: [:soumis, :traitement_en_cours]) }
  scope :visible_for_admins, -> { where(etat: [:creation, :soumis, :traitement_en_cours, :valide, :rejete, :valide_liquidation, :rejete_liquidation, :valide_inspection, :rejete_inspection]) }
  scope :existes, -> { where(etat: [:soumis, :traitement_en_cours, :valide, :valide_liquidation, :valide_inspection]) }
  scope :visible_valide_montant, -> { where(etat: [:valide, :valide_inspection]) }


  def full_name
    "#{prenom} #{nom}"
  end

  def generer_facture
    return if self.paiement?
    if valide_inspection? and not ComptaTransaction.exists?(dossier: self)
      if dossier_cnav.cnav?
        code_conv = 'CNAV'
      elsif dossier_cnav.caf_nord_conv?
        code_conv = 'CAF_NORD_CONV'
      elsif dossier_cnav.caf_coordination_benin?
        code_conv = 'CAF_COORD_BENIN'
      elsif dossier_cnav.caf_coordination_burkina?
        code_conv = 'CAF_COORD_BURKINA'
      elsif dossier_cnav.caf_coordination_civ?
        code_conv = 'CAF_COORD_CIV'
      elsif dossier_cnav.caf_coordination_gabon?
        code_conv = 'CAF_COORD_GABON'
      elsif dossier_cnav.caf_coordination_conakry?
        code_conv = 'CAF_COORD_CONAKRY'
      elsif dossier_cnav.caf_coordination_mali?
        code_conv = 'CAF_COORD_MALI'
      elsif dossier_cnav.caf_coordination_togo?
        code_conv = 'CAF_COORD_TOGO'
      elsif dossier_cnav.hors_conv_togo?
        code_conv = 'HORS_CONV_TOGO'
      elsif dossier_cnav.hors_conv_benin?
        code_conv = 'HORS_CONV_BENIN'
      elsif dossier_cnav.hors_conv_civ?
        code_conv = 'HORS_CONV_CIV'
      elsif dossier_cnav.hors_conv_gabon_rentes?
        code_conv = 'HORS_CONV_GABON_Rent'
      elsif dossier_cnav.hors_conv_gabon_retraite?
        code_conv = 'HORS_CONV_GABON_Ret'
      elsif dossier_cnav.hors_conv_conakry?
        code_conv = 'HORS_CONV_CONAKRY'
      elsif dossier_cnav.hors_conv_burkina?
        code_conv = 'HORS_CONV_BURK'
      elsif dossier_cnav.hors_conv_mali?
        code_conv = 'HORS_CONV_MALI'
      elsif dossier_cnav.conv_cipres_benin?
        code_conv = 'CONV_CIPRES_BENIN'
      elsif dossier_cnav.conv_cipres_burkina?
        code_conv = 'CONV_CIPRES_BURKINA'
      elsif dossier_cnav.conv_cipres_mali?
        code_conv = 'CONV_CIPRES_MALI'
      elsif dossier_cnav.conv_cipres_niger?
        code_conv = 'CONV_CIPRES_NIGER'
      elsif dossier_cnav.conv_cipres_togo?
        code_conv = 'CONV_CIPRES_TOGO'
      elsif dossier_cnav.cse
        code_conv = 'CSE'
      elsif dossier_cnav.enim
        code_conv = 'ENIM'
      end
      mois = ""
      unless dossier_cnav.mois.nil?
        mois = DossierCnav.human_enum_name(:mois, dossier_cnav.mois)
      end
      trimestre = ""
      unless dossier_cnav.trimestre.nil?
        trimestre = DossierCnav.human_enum_name(:trimestre, dossier_cnav.trimestre)
      end

      # FONCTION GENERATION FACTURE
      ActiveRecord::Base.transaction do
        ComptaTransaction.create(
          dossier: self,
          code_operation: "I_#{code_conv}",
          code_classe_evenement: 'LIQUIDATION',
          code_agence_liquidation: 'I_SG',
          numero_allocataire: numero,
          nom: nom,
          prenom: prenom,
          adresse: nil,
          mode_paiement: mode_paiement,
          code_banque_allocataire: nil,
          numero_compte_allocataire: nil,
          bank_id: nil,
          bank_branch_id: nil,
          date_debut_periode: nil,
          date_fin_periode: nil,
          montant: montant,
          code_devise: 'XOF',
          statut: :en_cours,
          description: "Paiement echeance #{code_conv} #{mois}/#{trimestre}/#{dossier_cnav.annee} #{numero} / #{origine}",
          admin_region: admin_region,
          zone: nil,
          admin_agence: nil,

          nin_allocataire: nil,
          telephone_allocataire: nil,
          mail_allocataire: nil,

          infos_paiement_id_bhs: nil,
          infos_paiement_id_ccp: nil,
          infos_paiement_libelle_ccp: nil,
          infos_paiement_succursale_cncas: nil,
        )

        self.paiement = true
        self.save
      end
    end
  end


  private


=begin
  def set_numero_liquidation!
    annee = Date.today.year
    nbreLiq = AllocataireCnav.soumis.count
    if AllocataireCnav.exists?(created_at: (DateTime.now.beginning_of_year..DateTime.now.end_of_year))
      dernier_ajoute = AllocataireCnav.where(created_at: (DateTime.now.beginning_of_year..DateTime.now.end_of_year)).order('created_at DESC').first
      self.numero_liquidation = derniere_ajoute.numero_liquidation.next
    else
      self.numero_liquidation = "#{dossier_maternite.mois}/#{annee}/LiquidAlloc001"
    end
  end
=end
end
