class AddColumnEmployeurActuelOld < ActiveRecord::Migration[5.2]
  def change
    add_column :dossier_prestations, :employeur_actuel_old, :string
  end
end
