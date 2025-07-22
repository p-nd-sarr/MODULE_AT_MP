class DemandeurReversion < ApplicationRecord
  ETAT = {
      en_attente: 0,
      soumis: 1,
      valide: 2,
      rejete: 3
  }.freeze

  TYPE_AYANT_DROIT = {
    veuve: 1,
    orphelin: 2
}.freeze

  enum etat: ETAT
  enum type_ayant_droit: TYPE_AYANT_DROIT

  belongs_to :base_reversion_salary, :class_name => 'BaseReversionSalary', foreign_key: :base_reversion_salary_id, optional: true
  has_one :enfant,:class_name => 'Enfant'
  has_one :conjoint,:class_name => 'Conjoint'
end
