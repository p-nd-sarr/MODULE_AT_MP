class IcmModifierInfoPersonnelle < ApplicationRecord
    belongs_to :dossier_maternite, class_name: 'DossierMaternite', foreign_key: :dossier_maternite_id,  optional: true
    belongs_to :ajoute_par, class_name: 'User', foreign_key: :ajoute_par_id,  optional: true

    ETAT = {
        creation: 1,
        soumis: 2,
        traitement_en_cours: 3,
        valide: 4,
        rejete: 5
    }.freeze

    enum etat: ETAT

    SEXE = {
        masculin: 1,
        feminin: 2,
    }.freeze
    enum sexe_salarie: SEXE
  
    TYPE_PIECE = {
        cni_tp: 1,
        passport: 2,
        cc: 3
    }.freeze
    enum type_piece: TYPE_PIECE
end
