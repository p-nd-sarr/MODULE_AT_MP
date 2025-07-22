class DossierAuditAffectation < ApplicationRecord

  belongs_to :dossier_audit, foreign_key: :dossier_audits_id
  belongs_to :affecte_par, class_name: 'User', foreign_key: :affecte_par_id
  belongs_to :affecte_a, class_name: 'User', foreign_key: :affecte_a_id

end