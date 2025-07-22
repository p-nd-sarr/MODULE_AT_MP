class AddColumnBenefiaireToDossierPrestation < ActiveRecord::Migration[5.2]
  def change
    add_column :dossier_prestations, :full_name_beneficiare, :string
  end
end
