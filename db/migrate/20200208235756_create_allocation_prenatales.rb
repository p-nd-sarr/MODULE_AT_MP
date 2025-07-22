class CreateAllocationPrenatales < ActiveRecord::Migration[5.2]
  def change
    create_table :allocation_prenatales do |t|
      t.references :dossier_prestation, foreign_key: true
      t.date :debut_grossesse
      t.integer :volet
      t.text :commentaire
      t.date :date_soumission
      t.date :date_validation
      t.integer :valide_par_id
      t.references :user, foreign_key: true

      t.timestamps
    end
  end
end
