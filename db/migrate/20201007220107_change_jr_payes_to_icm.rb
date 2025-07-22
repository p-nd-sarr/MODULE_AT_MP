class ChangeJrPayesToIcm < ActiveRecord::Migration[5.2]
  def change

    remove_column :indemnite_conges_maternites, :nbre_jr_payes

    add_column :indemnite_conges_maternites, :nbre_jr_payes, :integer, default: 0, null: false
    IndemniteCongesMaternite.where(nbre_jr_payes: nil).update_all(nbre_jr_payes: 0)
  end
end
