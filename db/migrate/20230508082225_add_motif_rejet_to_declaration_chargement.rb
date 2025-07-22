class AddMotifRejetToDeclarationChargement < ActiveRecord::Migration[5.2]
  def change
    add_column :declaration_chargements, :motif_rejet, :string
  end
end
