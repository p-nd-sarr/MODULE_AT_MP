class AddColumnNationalityToDossierPrestation < ActiveRecord::Migration[5.2]
  def change
    add_column :dossier_prestations, :nationalite, :integer
  end
end
