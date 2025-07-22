class ActivityRecommandation < ApplicationRecord

  include Documentable

  belongs_to :dossier_audit, foreign_key: :dossier_audits_id
  belongs_to :dossier_audit_activity, foreign_key: :dossier_audit_activities_id
  belongs_to :ajoute_par, class_name: 'User', foreign_key: :ajoute_par_id
  belongs_to :affecte_a, class_name: 'User', foreign_key: :affecte_a_id
  belongs_to :response_par, class_name: 'User', foreign_key: :response_par_id, optional: true

  has_one_attached :response_file
  validates :response_file, content_type: { in: 'application/pdf', message: "n'est pas un PDF" } #, attached: true

end

