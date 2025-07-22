class UpdateGrappeFamiliale < ApplicationRecord
  ETAT = {
      soumis: 2,
      affecte: 3,
      valide: 4,
      rejete: 5
  }.freeze

  TYPE_DEMANDE = {
      deces: 1,
      divorce: 2
  }

  enum etat: ETAT
  enum type_demande: TYPE_DEMANDE
  has_one_attached :attachment
  belongs_to :user, optional: true
  belongs_to :conjoint, optional: true
  belongs_to :enfant, optional: true
  belongs_to :traite_par, class_name: 'User', foreign_key: :traite_par_id, optional: true
  belongs_to :ajoute_par, class_name: 'User', foreign_key: :ajoute_par_id
  has_many :document_dossier_prestations, dependent: :destroy
  has_many :enfants, foreign_key: :numero_affiliation, primary_key: :num_affiliation
  has_many :conjoints, foreign_key: :numero_affiliation, primary_key: :num_affiliation
  belongs_to :traite_par, class_name: 'User', foreign_key: :traite_par_id, optional: true
  belongs_to :ajoute_par, class_name: 'User', foreign_key: :ajoute_par_id
  belongs_to :valider_par, class_name: 'User', foreign_key: :valider_par_id, optional: true
  belongs_to :affecter_allocataire, class_name: 'User', foreign_key: :affectation_allocataire, optional: true
  belongs_to :participant, :class_name => 'Psrm::Participant',
             foreign_key: :num_affiliation,
             primary_key: :matric,
             optional: true

  validates :num_affiliation, :prenom, :nom, :date_deces, :lieu_deces, presence: true


  validates :conjoint_id, uniqueness: {message: "Vous avez déjà une déclaration de décès pour ce conjoint"}, allow_nil: true
  validates :enfant_id, uniqueness: {message: "Vous avez déjà une déclaration de décès pour cet enfant"}, allow_nil: true
  validates :attachment, attached: true, content_type: {in: 'application/pdf', message: "n'est pas un PDF"}

  scope :en_attente, -> { where(etat: [:soumis, :traitement_en_cours]) }
  scope :visible_for_admins, -> { where(etat: [:soumis, :traitement_en_cours, :valide, :rejete]) }

  #before_validation :set_num_affiliation!
  #before_create :set_user!
  #before_create :set_numero_dossier!

  def full_name
    "#{prenom} #{nom}"
  end


  def pret_pour_soumission?
    etat_civil_demandeur_valid and conjoint_valid and enfants_valid and carriere_valid and document_valid
  end

  private


  def set_user!
    self.user = User.find_by(numero_salarie: num_affiliation)
  end

  def set_numero_dossier!
    annee = Date.today.year
    if UpdateGrappeFamiliale.exists?(num_affiliation: num_affiliation, created_at: (DateTime.now.beginning_of_year..DateTime.now.end_of_year))
      dernier_dossier_ajoute = UpdateGrappeFamiliale.where(num_affiliation: num_affiliation, created_at: (DateTime.now.beginning_of_year..DateTime.now.end_of_year)).order('created_at DESC').first
      self.num_dossier = dernier_dossier_ajoute.num_dossier.next
    else
      self.num_dossier = "#{num_affiliation}/#{annee}/DOSSPR0001"
    end
  end
end
  