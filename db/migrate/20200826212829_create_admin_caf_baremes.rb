class CreateAdminCafBaremes < ActiveRecord::Migration[5.2]
  def change
    create_table :admin_caf_baremes do |t|
      t.integer :periode, null: false
      t.float :montant_indemnites, null: false
      t.date :date_debut_validite, null: false
      t.date :date_fin_validite, null: false

      t.timestamps
    end
  end
end
