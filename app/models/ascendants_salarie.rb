class AscendantsSalarie < ApplicationRecord

  TYPE_PIECE_PERE = {
      extrait_naissance_p: 1,
      cni_p: 2,
  }.freeze

  TYPE_PIECE_MERE = {
    extrait_naissance_m: 1,
    cni_m: 2
}.freeze

  enum type_piece_pere: TYPE_PIECE_PERE
  enum type_piece_mere: TYPE_PIECE_MERE

  #has_one_attached :piece_identite
  has_one_attached :piece_pere
  has_one_attached :piece_mere

  validates :prenom_mere, :nom_mere, :date_naissance_mere, :prenom_pere, :nom_pere, :date_naissance_pere, :date_naissance_salarie,
            presence: true

  validates :piece_pere, attached: true, content_type: {in: 'application/pdf', message: "n'est pas un PDF"}
  validates :piece_mere, attached: true, content_type: {in: 'application/pdf', message: "n'est pas un PDF"}

  validate :validate_numero_affiliation

  validates :numero_piece_pere, :numero_piece_mere, uniqueness: true, presence: true, length: { in: 13..14 }

  validates :numero_affiliation, presence: true, uniqueness: {message: "Vous avez déja enregistré vos ascendants."}

  validate :valider_age_mere_salarie
  validate :valider_nin
  validate :valider_uniq_cni, on: :create

  private

  def validate_numero_affiliation
    return if numero_affiliation.nil? or numero_affiliation.empty?
    errors.add(:numero_affiliation, "Ce numéro d'affiliation est introuvable.") unless Psrm::Participant.where(matric: numero_affiliation).exists?
  end

  def valider_age_mere_salarie
    if date_naissance_mere >= date_naissance_salarie
      errors.add(:base, "L'âge de la mere doit être antérieur à la date de naissance du salarié.")
    end
  end

  def valider_nin
    if numero_piece_mere[0].to_i != 2
      errors.add(:numero_piece_mere, "Le numéro de pièce de la mère doit commencer par \"2\" .")
    elsif numero_piece_pere[0].to_i != 1
      errors.add(:numero_piece_pere, "Le numéro de pièce du père doit commencer par \"1\" .")
    end
  end

  def valider_uniq_cni
    if Conjoint.all.pluck(:numero_piece).include? numero_piece_mere
      errors.add(:numero_piece, 'numéro de pièce invalide ou conoint déja en union')
    elsif Conjoint.all.pluck(:numero_piece).include? numero_piece_pere
      errors.add(:numero_piece, 'numéro de pièce invalide ou conoint déja en union')
    elsif Enfant.all.pluck(:numero_piece).include? numero_piece_mere
      errors.add(:numero_piece, 'NIN déja enregistré. ')

    elsif Enfant.all.pluck(:numero_piece).include? numero_piece_pere
      errors.add(:numero_piece, 'NIN déja enregistré. ')

    elsif AscendantsSalarie.all.pluck(:numero_piece_mere).include? numero_piece_mere
      errors.add(:numero_piece, 'NIN déja enregistré. ')

    elsif AscendantsSalarie.all.pluck(:numero_piece_pere).include? numero_piece_pere
      errors.add(:numero_piece, 'NIN déja enregistré. ')
    end
  end

end
