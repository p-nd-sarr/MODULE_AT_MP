class AddNumeroDossierToReversionVeuve < ActiveRecord::Migration[5.2]
  def change
    add_column :reversion_veuves, :numero_dossier, :string, null: false
  end
end
