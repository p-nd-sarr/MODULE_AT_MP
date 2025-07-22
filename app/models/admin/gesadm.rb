class Admin::Gesadm < ApplicationRecord

    SEXE = {
        homme: 0,
        femme: 1
      }.freeze
    
      enum sexe: SEXE

      NATION = {
        senegalais: 1,
        etranger: 2
    }
    enum nation: NATION
    belongs_to :etablissement, :class_name => 'Admin::Etablissement', foreign_key: :CDEETAB, optional: true
end
