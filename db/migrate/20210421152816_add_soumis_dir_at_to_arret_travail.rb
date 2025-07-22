class AddSoumisDirAtToArretTravail < ActiveRecord::Migration[5.2]
  def change
    add_column :arret_travails, :soumis_dir_at_par, :integer
  end
end
