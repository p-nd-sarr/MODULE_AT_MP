class CreateRegulationPension < ActiveRecord::Migration[5.2]
  def change
    create_table :regulation_pensions do |t|
      t.references :allocataire, foreign_key: true
      t.string :numero_allocataire
      t.string :prenom
      t.string :nom
      t.date :date_regulation
      t.date :date_soumission
      t.date :date_validation
      t.integer :valide_par_id
      t.references :user, foreign_key: true
      t.integer :ajoute_par_id
      t.datetime :traite_le
      t.integer :traite_par_id
      t.integer :motif_regulation_pension
      t.integer :montant_regulation
      t.integer :etat
      t.string :attachment
      t.timestamps
    end
  end
end
