class CssFiabilisationHistoric < ApplicationRecord

  belongs_to :dossier, polymorphic: true, optional: true
  belongs_to :ajoute_par, class_name: 'User', foreign_key: :ajoute_par_id
end
