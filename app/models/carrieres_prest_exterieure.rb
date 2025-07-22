class CarrieresPrestExterieure < ApplicationRecord
    ETAT = {
        en_attente: 0,
        valide: 1,
        rejete: 2,
        a_rembourse: 3
    }.freeze
    enum etat: ETAT
    belongs_to :cfs_reversion_veuve, optional: true
    belongs_to :employeur_exterieur, optional: true

end