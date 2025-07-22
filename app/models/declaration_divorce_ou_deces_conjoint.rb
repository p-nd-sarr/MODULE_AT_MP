class DeclarationDivorceOuDecesConjoint < ApplicationRecord
  TYPE_PIECE = {
      certificat_divorce: 1,
      certificat_deces: 2
  }.freeze

  enum type_piece: TYPE_PIECE

  ETAT = {
      divorcer: 1,
      deceder: 2
  }.freeze

  enum status_with_conjoint: ETAT

  belongs_to :conjoint

  has_one_attached :piece_jointe

  validates :piece_jointe, attached: true, content_type: {in: 'application/pdf', message: "n'est pas un PDF"}

  validate :validate_numero_affiliation

  validate :valider_date_declaration

  after_save :update_status_conjoint_in_conjoint

  def valider_date_declaration
    if date_declaration > Date.today
      errors.add(:date_declaration, "La date de déclaration ne peut être postérieur à la date du jour. ")
    end
  end


  def update_status_conjoint_in_conjoint
    unless self.conjoint.nil?
      self.conjoint.update_columns(etat_conjoint: self.status_with_conjoint)
      if self.deceder?
        self.conjoint.update_columns(date_deces: self.date_declaration)
      else
        self.conjoint.update_columns(date_divorce: self.date_declaration)
      end
    end
    self.conjoint.save
  end

  private

  def validate_numero_affiliation
    return if numero_affiliation.nil? or numero_affiliation.empty?
    errors.add(:numero_affiliation, "Ce numéro d'affiliation est introuvable") unless Psrm::Participant.where(matric: numero_affiliation).exists? #or Allocataire.where(numero_allocataire: numero_affiliation).exists?
  end

end
