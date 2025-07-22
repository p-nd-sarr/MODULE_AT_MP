class RemoveValPointAndTauxFromBareme < ActiveRecord::Migration[5.2]
  def change
    remove_column :admin_baremes, :valeur_point
    remove_column :admin_baremes, :taux
  end
end
