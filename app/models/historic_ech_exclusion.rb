class HistoricEchExclusion < ApplicationRecord

  belongs_to :echeance_caisse
  belongs_to :echeance_caisse_employeur
  belongs_to :dossier_prestation, foreign_key: :dossier_presttaion_id
  belongs_to :ajoute_par, class_name: 'User', foreign_key: :ajoute_par_id
end
