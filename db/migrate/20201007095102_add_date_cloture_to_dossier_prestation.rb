class AddDateClotureToDossierPrestation < ActiveRecord::Migration[5.2]
  def change
    add_column :dossier_prestations, :date_cloture, :date
  end
end
