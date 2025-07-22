class AddColumnsValidateByToIcm < ActiveRecord::Migration[5.2]
  def change
    add_column :dossier_maternites, :soumis_par_id, :integer
  end
end
