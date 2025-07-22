class DossierCnav < ApplicationRecord
  include ActionView

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

  MOIS = {
    janvier: 1,
    fevrier: 2,
    mars: 3,
    avril: 4,
    mai: 5,
    juin: 6,
    juillet: 7,
    aout: 8,
    septembre: 9,
    octobre: 10,
    novembre: 11,
    decembre: 12
  }.freeze
  enum mois: MOIS

  TRIMESTRE = {
    premier: 1,
    deuxieme: 2,
    troisieme: 3,
    quatrieme: 4
  }.freeze
  enum trimestre: TRIMESTRE

  USAGE = {
    a_payer: 1,
    a_envoyer: 2
  }.freeze
  enum usage: USAGE

  TYPE_CONVENTION = {
    cnav: 1,
    caf_nord_conv: 2,
    caf_coordination_benin: 3,
    caf_coordination_burkina: 32,
    caf_coordination_civ: 34,
    caf_coordination_gabon: 35,
    caf_coordination_conakry: 36,
    caf_coordination_mali: 33,
    caf_coordination_togo: 31,
    hors_conv_benin: 41,
    hors_conv_burkina: 43,
    hors_conv_civ: 42,
    hors_conv_gabon_rentes: 46,
    hors_conv_gabon_retraite: 45,
    hors_conv_conakry: 47,
    hors_conv_mali: 44,
    hors_conv_togo: 4,
    conv_cipres_benin: 104,
    conv_cipres_burkina: 102,
    conv_cipres_mali: 101,
    conv_cipres_niger: 103,
    conv_cipres_togo: 10,
    cse: 11,
    enim: 12
  }.freeze
  enum type_convention: TYPE_CONVENTION

  belongs_to :user, optional: true
  belongs_to :ajoute_par, class_name: 'User', foreign_key: :ajoute_par_id
  belongs_to :traite_par, class_name: 'User', foreign_key: :traite_par_id, optional: true
  belongs_to :valider_par, class_name: 'User', foreign_key: :valider_par_id, optional: true
  belongs_to :valider_liq_par, class_name: 'User', foreign_key: :valider_liq_par_id, optional: true
  belongs_to :valider_insp_par, class_name: 'User', foreign_key: :valider_insp_par_id, optional: true

  has_many :allocataire_cnavs, dependent: :destroy

  # has_many :ordre_paiements, as: :dossier, dependent: :destroy
  # has_many :compta_transactions, through: :ordre_paiements

  validates :motif_rejet, presence: true, if: :rejete?
  validates :annee, :date_ouverture, :type_convention, :usage, presence: true
  # validates :type_convention, uniqueness: { scope: [:mois, :annee, :usage], message: ": déjà enregistré pour cette periode"}, if: :trimestre.nil?
  # validates :type_convention, uniqueness: { scope: [:annee, :trimestre, :usage], message: ": déjà enregistré pour cette periode"}, if: :mois.nil?

  scope :en_attente, -> { where(etat: [:soumis, :traitement_en_cours]) }
  scope :visible_for_admins, -> { where(etat: [:creation, :soumis, :traitement_en_cours, :valide, :rejete, :valide_liquidation, :rejete_liquidation, :valide_inspection, :rejete_inspection]) }

  validate :mois_ou_trimestre_present
  # validate :unique_dossier_per_period
  before_create :set_numero_dossier!, :set_date_ouverture!

  def attente_paiement?
    # not valide? and not allocataire_cnavs.valide.non_paye.empty?
    valide_inspection? and not allocataire_cnavs.valide_inspection.non_paye.empty?
  end

  def self.my_import(file, user_id, dossier_cnav)
    user = User.find(user_id)

    delta = 1
    last_dossier = DossierCnav.where(type_convention: dossier_cnav.type_convention).order('created_at desc').second
    list_alloc = last_dossier.allocataire_cnavs unless last_dossier.nil?

    puts("-------- ****************** ----------")
    puts(list_alloc.count) unless list_alloc.nil?
    puts("-------- ****************** ----------")
    puts(file.path)
    xlsx = Roo::Spreadsheet.open(file.path).sheet(0)
    xlsx.each_row_streaming(offset: 1) do |row|
      # puts(row)
      unless row[0].nil?
        numero = row[0].value
      else
        numero = ""
      end
      unless row[1].nil?
        prenom = row[1].value
      else
        prenom = ""
      end
      unless row[2].nil?
        nom = row[2].value
      else
        nom = ""
      end
      unless row[6].nil?
        origine = row[6].value
      else
        origine = ""
      end
      unless row[7].nil?
        caisse = row[7].value
      else
        caisse = ""
      end
      unless row[9].nil?
        iban = row[9].try(:value)
      else
        iban = ""
      end

      region = row[3].try(:value)
      mode = row[4].try(:value)
      montant = row[5].try(:value)

      unless row[8].nil?
        compte = row[8].try(:value)
      else
        compte = ""
      end

      unless list_alloc.nil?
        last_alloc = list_alloc.find_by(numero: numero) unless list_alloc.empty?
        if last_alloc.nil?
          delta = 1
        else
          delta = 2
        end
      end

      a = AllocataireCnav.create(
        etat: 1,
        delta: delta,
        numero: numero,
        prenom: prenom,
        nom: nom,
        admin_region: Admin::Region.find_by(code: region),
        mode_paiement: mode,
        montant: montant.to_i,
        origine: origine,
        admin_banque: Admin::Banque.find_by(code: caisse),
        compte: compte,
        iban: iban,
        user: user,
        ajoute_par: user,
        date_import: Date.today,
        dossier_cnav: dossier_cnav
      )
      puts("____***********************____")
      puts(a.errors.messages)
    end

    unless list_alloc.nil?
      dernier_chargement = dossier_cnav.allocataire_cnavs
      # puts("____***********************MARIEME ____#{dossier_cnav.type_convention}")
      # puts("____***********************MARIEME ____#{dernier_chargement.count}")
      # puts("____***********************MARIEME ____#{dossier_cnav.type_convention}")
      # puts("____***********************MARIEME ____#{dossier_cnav.type_convention}")
      list_alloc.each do |allocataire_cnav|
        allocataire = dernier_chargement.find_by(numero: allocataire_cnav.numero) unless dernier_chargement.empty?
        if allocataire.nil?
          allocataire_cnav.delta = 3
        end
        allocataire_cnav.save
      end
    end

  end

  private

  def mois_ou_trimestre_present
    # unless mois.present? || trimestre.present?
    #   errors.add(:base, "Le mois ou le trimestre doit être présent")
    # end
    if creation?
      if mois.present? && trimestre.present?
        errors.add(:base, "Seul le mois ou le trimestre peut être présent, pas les deux")
      elsif mois.blank? && trimestre.blank?
        errors.add(:base, "Au moins le mois ou le trimestre doit être présent")
      end
    end
  end

  def unique_dossier_per_period
    if creation?
      if mois.present?
        if DossierCnav.exists?(type_convention: type_convention, annee: annee, mois: mois, usage: usage)
          errors.add(:base, "Mois - Un dossier avec la même année, le même mois et le même usage existe déjà")
        end
      elsif trimestre.present?
        if DossierCnav.exists?(type_convention: type_convention, annee: annee, trimestre: trimestre, usage: usage)
          errors.add(:base, "Trimestre - Un dossier avec la même année, le même trimestre et le même usage existe déjà")
        end
        # elsif mois.present? and trimestre.present?
        #   errors.add(:base, "Soit le mois ou le trimestre doit être renseigné")
      else
        errors.add(:base, "Le mois ou le trimestre doit être renseigné")
      end
    end
  end

  def set_numero_dossier!
    numero_ordre = DossierCnav.where(annee: self.annee, type_convention: self.type_convention).
      maximum(:numero_dossier).
      try(:split, '/').
      try(:last).
      try(:next) || 1

    if cnav?
      code_conv = 'CNAV'
    elsif caf_nord_conv?
      code_conv = 'CAF_NORD_CONV'
    elsif caf_coordination_benin?
      code_conv = 'CAF_COORDINATION_BENIN'
    elsif caf_coordination_burkina?
      code_conv = 'CAF_COORD_BURKINA'
    elsif caf_coordination_conakry?
      code_conv = 'CAF_COORD_CONAKRY'
    elsif caf_coordination_civ?
      code_conv = 'CAF_COORD_CIV'
    elsif caf_coordination_gabon?
      code_conv = 'CAF_COORD_GABON'
    elsif caf_coordination_mali?
      code_conv = 'CAF_COORD_MALI'
    elsif caf_coordination_togo?
      code_conv = 'CAF_COORD_TOGO'
    elsif hors_conv_togo?
      code_conv = 'HORS_CONV_TOGO'
    elsif hors_conv_benin?
      code_conv = 'HORS_CONV_BENIN'
    elsif hors_conv_civ?
      code_conv = 'HORS_CONV_CIV'
    elsif hors_conv_burkina?
      code_conv = 'HORS_CONV_BURK'
    elsif hors_conv_mali?
      code_conv = 'HORS_CONV_MALI'
    elsif hors_conv_gabon_rentes?
      code_conv = 'HORS_CONV_GAB_RENT'
    elsif hors_conv_gabon_retraite?
      code_conv = 'HORS_CONV_GAB_RETR'
    elsif hors_conv_conakry?
      code_conv = 'HORS_CONV_CONAKRY'
    elsif conv_cipres_benin?
      code_conv = 'CONV_CIPRES_BENIN'
    elsif conv_cipres_burkina?
      code_conv = 'CONV_CIPRES_BURKINA'
    elsif conv_cipres_mali?
      code_conv = 'CONV_CIPRES_MALI'
    elsif conv_cipres_niger?
      code_conv = 'CONV_CIPRES_NIGER'
    elsif conv_cipres_togo?
      code_conv = 'CONV_CIPRES_TOGO'
    elsif cse?
      code_conv = 'CSE'
    elsif enim?
      code_conv = 'ENIM'
    end
    # self.numero_dossier = "CNAV/#{annee}/#{self.mois}/#{numero_ordre}"
    self.numero_dossier = "#{code_conv}/#{annee}/#{numero_ordre}"
  end

  def set_date_ouverture!
    self.date_ouverture = DateTime.now if self.date_ouverture.nil?
  end

end
