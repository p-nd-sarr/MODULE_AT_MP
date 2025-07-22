class AddDateEmbaucheToDossierPrestation < ActiveRecord::Migration[5.2]
  def change
    add_column :dossier_prestations, :date_embauche, :date
  end
end
