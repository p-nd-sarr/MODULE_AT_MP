# frozen_string_literal: true

class User < ApplicationRecord
  include UserActsAsSalarie
  include UserActsAsAllocataire
  include UserActsAsAdmin
  include Activable
  include UserActsAsEmployer

  TYPE_SEXE = {
      homme: 1,
      femme: 2
  }.freeze

  TYPE_PROFIL = {
    super_admin: 0,
    admin: 1,
    gestionnaire_compte_employeur: 101,
    gestionnaire_compte_salarie: 102,
    gestionnaire_compte_allocataire: 103,
    chef_service_allocation: 104,
    chef_agence: 105,
    comptable: 106,
    chef_service_cotisation: 107,
    chef_section_instruction: 108,
    chef_section_liquidation: 109,
    directeur_prestation: 110,
    chef_service_contentieux: 111,
    salarie: 201,
    allocataire: 202,
    employeur: 203,
    agent_accueil: 204,
    chef_subdivision_atmp: 205,
    redacteur: 206,
    dajc: 207,
    dprp: 208,
    chef_division_at: 209,
    directeur_at: 210,
    medecin_conseil: 211,
    chef_groupe_caf: 212,
    chef_subdivision_caf: 213,
    agent_accueil_direction_at: 214,
    technicien_at: 215,
    technicien_direction_at: 216,
    directeur_general: 217,
    inspection: 218,
    consultation: 219,
    chef_service_prest_ext: 300,
    controleur_css: 301,
    auditeur_css: 302,
    agent_dfc: 303,
    chef_service_dfc: 304,
    caissier_ipres: 401,
    directeur_juridique: 501,
    chef_service_direction_juridique: 502,
    agent_direction_juridique: 503,
    auditeur: 602,
    chef_service_audit: 603,
    chef_service_controle_interne: 604,
    directeur_audit: 605
  }.freeze

  enum type_profil: TYPE_PROFIL
  enum sexe: TYPE_SEXE

  # Include default devise modules. Others available are:
  # :timeoutable and :omniauthable
  devise :database_authenticatable, :registerable, :lockable,
         :recoverable, :rememberable, :validatable, :trackable, :confirmable, :timeoutable,
         timeout_in: Rails.env.development? ? 10.days : 60.minutes

  scope :en_agence, ->(id) { where(agence_id: id) }
  scope :users_for_type, ->(profil) { where(type_profil: profil) }
  scope :validators_for_audit, -> { where(type_profil: [:directeur_audit, :directeur_juridique, :directeur_prestation, :directeur_at, :dajc, :dprp]) }
  scope :for_created_by_search, -> { where(type_profil: [:gestionnaire_compte_allocataire, :gestionnaire_compte_salarie]) }

  validate :uniqueness_of_ninea, if: -> { employeur? }, on: :create
  validates :prenom, :nom, :type_profil, presence: true, if: -> { not employeur? }
  validates :telephone,  presence: true, phone: {possible: true, allow_blank: true, types: [:mobile]} #, country_specifier: -> phone { phone.country.try(:upcase) } }

  belongs_to :created_by, class_name: 'User', foreign_key: :created_by_id, optional: true
  belongs_to :activated_by, class_name: 'User', foreign_key: :activated_by_id, optional: true
  belongs_to :admin_agence, optional: true, :class_name => 'Admin::Agence', foreign_key: :agence_id
  belongs_to :admin_type_employeur, :class_name => 'Admin::TypeEmployeur', foreign_key: :type_employeur, optional: true

  has_one :immatriculation
  has_one :representant_legal

  has_many :enfants, foreign_key: :numero_affiliation, primary_key: :numero_salarie
  has_many :conjoints, foreign_key: :numero_affiliation, primary_key: :numero_salarie
  has_many :salarie_immatriculations
  has_many :document_immatriculations
  has_many :declarations
  has_many :moratoires
  has_many :paiements
  has_many :modifier_adresses
  has_many :modifier_mode_paiements
  has_many :allocation_prenatales
  has_many :carrieres, class_name: 'Psrm::Carriere', foreign_key: :matric, primary_key: :numero_affiliation
  has_many :carrieres_prestation, class_name: 'Carriere', foreign_key: :numero_affiliation, primary_key: :numero_affiliation
  has_many :trackings, dependent: :destroy
  has_many :salary_modification_historiques
  has_one_attached :cni_file
  has_one_attached :image_profile
  has_many :emploi_precedents, dependent: :destroy
  accepts_nested_attributes_for :emploi_precedents
  has_one_attached :certificat_travail_actuel
  has_one_attached :certificat_travail_precedent


  validates :cni_file, attached: true, content_type: {in: 'application/pdf', message: "n'est pas un PDF"}, if: -> { self.salarie? }
  validates :certificat_travail_actuel, attached: true, content_type: {in: 'application/pdf', message: "n'est pas un PDF"}, if: -> { self.salarie? }
  #validates :certificat_travail_precedent, content_type: {in: 'application/pdf', message: "n'est pas un PDF"}

  belongs_to :agence, :class_name => 'Admin::Agence', foreign_key: :agence_id, optional: true

  after_create :create_immatriculation!

  def active_for_authentication?
    # Uncomment the below debug statement to view the properties of the returned self model values.
    # logger.debug self.to_yaml

    super && actif?
  end

  def user_back_office?
    super_admin? or admin? or gestionnaire_compte_employeur? or gestionnaire_compte_salarie? or gestionnaire_compte_allocataire? or controleur_css? or chef_service_allocation? or chef_service_prest_ext? or chef_service_cotisation? or chef_agence? or comptable? or chef_section_liquidation? or chef_section_instruction? or directeur_prestation? or agent_accueil? or chef_subdivision_atmp? or redacteur? or dajc? or dprp? or chef_division_at? or medecin_conseil? or directeur_at? or chef_groupe_caf? or chef_subdivision_caf? or agent_accueil_direction_at? or technicien_at? or technicien_direction_at? or chef_service_contentieux? or directeur_general? or consultation? or inspection? or auditeur_css? or agent_dfc? or chef_service_dfc? or agent_direction_juridique? or directeur_juridique? or chef_service_direction_juridique? or chef_service_prest_ext? or auditeur? or chef_service_audit? or chef_service_controle_interne? or directeur_audit?
  end

  def can_allocataire?
    super_admin? or admin? or gestionnaire_compte_allocataire? or gestionnaire_compte_salarie? or chef_service_allocation? or chef_service_prest_ext? or chef_service_cotisation?
  end

  def can_show_admin?
    chef_service_allocation? or chef_service_prest_ext? or chef_section_instruction? or chef_section_liquidation? or directeur_prestation? or chef_service_cotisation? or directeur_general?
  end

  def gestionnaire_ipres?
    self.gestionnaire_compte_allocataire? and self.admin_agence.ipres?
  end

  def gestionnaire_css?
    self.gestionnaire_compte_salarie? and self.admin_agence.css?
  end

  def type_profil_he_can_create
    return User::TYPE_PROFIL.keys if super_admin?
    return User::TYPE_PROFIL.keys - [:super_admin] if admin?
    return [:salarie] if gestionnaire_compte_salarie?
    return [:allocataire] if gestionnaire_compte_allocataire?
    return [:employeur] if gestionnaire_compte_employeur?
    []
  end

  def full_name
    "#{prenom} #{nom}"
  end

  def full_name_with_profile
    "#{prenom} #{nom} (#{type_profil.humanize})"
  end

  def phone_notif
    Phonelib.parse(telephone).sanitized
  end

  def phone_national
    Phonelib.parse(telephone).national
  end

  def create_immatriculation!
    if self.employeur? and ::Immatriculation.find_by(user: self).nil?
      @employeur = Psrm::Employeur.find_by(ancien_num_ipres: num_ipres)
      ::Immatriculation.create(
          raison_sociale: @employeur.nil? ? raison_sociale : @employeur.fhrsoc,
          ninea: ninea,
          adresse: @employeur.nil? ? "" : @employeur.fhadr,
          type_employeur: self.type_employeur,
          etat: :creation,
          user: self)
    end
  end

  def uniqueness_of_ninea
    existing_ninea = User.find_by_ninea(ninea)
    unless existing_ninea.nil?
      errors.add(:ninea, "Ninea #{ninea} existe déja")
    end
  end

  def self.current
    Thread.current[:user]
  end

  def self.current=(user)
    Thread.current[:user] = user
  end

  def can_instruction?
    chef_agence? and admin_agence.present? and admin_agence.ipres?
  end

  def upload_is_image
    unless image_profile and image_profile.content_type =~ /^image_profile\/(jpeg|jpg|png)$/
      errors.add(:upload, "Not a valid image")
    end
  end

end
