class AddColumnConjointToEcheanceVeuvesCaisseEnfant < ActiveRecord::Migration[5.2]
  def change
    add_reference :echeance_veuves_caisse_enfants, :conjoint, foreign_key: true
  end
end
