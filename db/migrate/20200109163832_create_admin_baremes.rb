class CreateAdminBaremes < ActiveRecord::Migration[5.2]
  def change
    create_table :admin_baremes do |t|
      t.references :admin_type_regime, foreign_key: true, null: false
      t.integer :periode, null: false
      t.float :valeur_point, null: false
      t.float :taux, null: false
      t.float :plafond_salaire, null: false
      t.date :date_debut_validite, null: false
      t.date :date_fin_validite, null: false

      t.timestamps
    end
  end
end
