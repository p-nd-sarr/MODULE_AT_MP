module UserActsAsAdmin
  extend ActiveSupport::Concern

  included do
    has_many :liquidation_retraite_creees, class_name: 'LiquidationRetraite', foreign_key: :ajoute_par_id
    has_many :liquidation_retraite_france_creees, class_name: 'LiquidationRetraiteFrance', foreign_key: :ajoute_par_id
    has_many :dossier_prestation_crees, class_name: 'DossierPrestation', foreign_key: :ajoute_par_id
    has_many :dossier_maternite_crees, class_name: 'DossierMaternite', foreign_key: :ajoute_par_id
    has_many :dossier_cnav_crees, class_name: 'DossierCnav', foreign_key: :ajoute_par_id
    has_many :cfs_reversion_veuve_creees, class_name: 'CfsReversionVeuve', foreign_key: :ajoute_par_id
    has_many :reversion_veuves_crees, class_name: 'ReversionVeuve', foreign_key: :ajoute_par_id
  end

  private

end