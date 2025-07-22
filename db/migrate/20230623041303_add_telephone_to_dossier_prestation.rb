class AddTelephoneToDossierPrestation < ActiveRecord::Migration[5.2]
  def change
    add_column :dossier_prestations, :telephone, :string
  end
end
