class AddInfosTraitementToDeclarationChargement < ActiveRecord::Migration[5.2]
  def change
    add_column :declaration_chargements, :traite_par_id, :integer
    add_column :declaration_chargements, :traite_le, :datetime
  end
end
