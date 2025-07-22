class CreateRegularisationPensions < ActiveRecord::Migration[5.2]
  def change
    create_table :regularisation_pensions do |t|
      t.references :allocataire, foreign_key: true
          t.string :numero_allocataire
          t.string :prenom
          t.string :nom
          t.date :date_regularisation
          t.date :date_soumission
          t.date :date_validation
          t.integer :valide_par_id
          t.references :user, foreign_key: true
          t.integer :ajoute_par_id
          t.datetime :traite_le
          t.integer :traite_par_id
          t.integer :motif_regularisation_pension
          t.integer :montant_regularisation
          t.integer :affectation_allocataire
          t.date :affectation_allocataire_date
          t.integer :duree_suspension
          t.integer :etat
          t.string :attachment
          t.string :motif_rejet
    end
  end
end
