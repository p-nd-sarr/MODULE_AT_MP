class CreatePsrmEmployeur < ActiveRecord::Migration[5.2]
  def change
    create_table :psrm_employeurs do |t|
      t.string :fhnum, null: false, limit: 20
      t.string :ancien_num_ipres, limit: 30
      t.string :ancien_num_css, limit: 30
      t.string :fhrsoc, null: false
      t.string :activite_prinicipal
      t.string :fhbp, limit: 20
      t.string :fhadr
      t.string :fhtel, limit: 30
      t.date :fheffa
      t.string :taux_at
      t.float :solde_pf, default: 0
      t.float :solde_at, default: 0
      t.float :solde_ve, default: 0
      t.float :solde_total, default: 0
      t.string :statut
      t.string :ancien_statut_ipres
      t.string :ancien_statut_css
    end
  end
end
