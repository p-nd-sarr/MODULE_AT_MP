class CarrieresExterieure < ApplicationRecord
    ETAT = {
        en_attente: 0,
        valide: 1,
        rejete: 2,
        a_rembourse: 3
    }.freeze
    enum etat: ETAT

    PROVENANCE = {
      retraite: 0,
      reversion: 1
    }.freeze
    enum provenance: PROVENANCE

    belongs_to :liquidation_retraite_france, class_name: 'LiquidationRetraiteFrance', foreign_key: :liquidation_retraite_france_id, optional: true
    belongs_to :cfs_reversion_veuve, optional: true
    belongs_to :employeur_exterieur, optional: true

    # validates :date_debut, :date_fin, :salaire, :employeur_exterieur_id, presence: true
end