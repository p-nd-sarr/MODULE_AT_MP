class AddColumnNbFemmesDatesMariage < ActiveRecord::Migration[5.2]
  def change
    add_column :conjoints, :nombre_femmes, :integer
    add_column :conjoints, :date_etablissement_mariage, :date
    add_column :conjoints, :date_jugement_suppletif, :date
  end
end
