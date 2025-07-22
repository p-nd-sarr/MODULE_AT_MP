class CreateEcheanceCaisses < ActiveRecord::Migration[5.2]
  def change
    create_table :echeance_caisses do |t|
      t.integer :annee
      t.integer :trimestre
      t.string :workflow_state, limit: 50
      t.date :periode_debut
      t.date :periode_fin

      t.timestamps
    end
  end
end
