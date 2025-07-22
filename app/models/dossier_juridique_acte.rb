class DossierJuridiqueActe < ApplicationRecord

  TYPE_ACT = {
    audience: 0,
    seance: 1
  }
  enum type_act: TYPE_ACT

  has_one_attached :pv_audience
  has_one_attached :pv_assignation
  has_one_attached :pv_decision

  validates :type_act, :dossier_juridique_id, :date_act, :comment, presence: true
  validates :pv_audience, content_type: { in: 'application/pdf', message: "n'est pas un PDF" } #, attached: true
  validates :pv_assignation, content_type: { in: 'application/pdf', message: "n'est pas un PDF" } #, attached: true
  validates :pv_decision, content_type: { in: 'application/pdf', message: "n'est pas un PDF" } #, attached: true

  belongs_to :dossier_juridique, foreign_key: :dossier_juridique_id
  belongs_to :ajoute_par, class_name: 'User', foreign_key: :ajoute_par_id, optional: true

  scope :audiences, -> { where(type_act: :audience) }
  scope :seances, -> { where(type_act: :seance) }

end
