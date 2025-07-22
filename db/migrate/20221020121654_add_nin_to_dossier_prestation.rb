class AddNinToDossierPrestation < ActiveRecord::Migration[5.2]
  def change
    add_column :dossier_prestations, :nin, :string
  end
end
