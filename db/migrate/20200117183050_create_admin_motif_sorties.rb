class CreateAdminMotifSorties < ActiveRecord::Migration[5.2]
  def change
    create_table :admin_motif_sorties do |t|
      t.string :code
      t.string :description

      t.timestamps
    end
  end
end
