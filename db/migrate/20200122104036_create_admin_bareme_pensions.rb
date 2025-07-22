class CreateAdminBaremePensions < ActiveRecord::Migration[5.2]
  def change
    create_table :admin_bareme_pensions do |t|
      t.references :admin_type_regime, foreign_key: true
      t.date :date_debut_validite, null: false
      t.date :date_fin_validite, null: false
      t.float :valeur_point_annuelle, null: false
      t.float :valeur_point_trimestrielle
      t.float :valeur_point_bimestrielle
      t.float :valeur_point_mensuelle

      t.timestamps
    end
  end
end
