class AddColumToEnfant < ActiveRecord::Migration[5.2]
  def change
    add_column :enfants, :sexe, :integer
    add_column :enfants, :numero_registre, :integer
    add_column :enfants, :code_etat_civil, :string
  end
end
