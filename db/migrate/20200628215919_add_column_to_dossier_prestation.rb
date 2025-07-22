class AddColumnToDossierPrestation < ActiveRecord::Migration[5.2]
  def change
    add_column :dossier_prestations, :full_name_conjoint, :string
  end
end
