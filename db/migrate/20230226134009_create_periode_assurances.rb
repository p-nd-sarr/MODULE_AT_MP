class CreatePeriodeAssurances < ActiveRecord::Migration[5.2]
  def change
    create_table :periode_assurances do |t|
      t.references :cfs_reversion_veuve, foreign_key: true
      t.date :date_debut
      t.date :date_fin
      t.integer :trimestre_assurance
      t.integer :trimestre_equivalente
      t.integer :type_periode

      t.timestamps
    end
  end
end
