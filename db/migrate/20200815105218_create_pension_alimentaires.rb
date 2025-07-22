class CreatePensionAlimentaires < ActiveRecord::Migration[5.2]
  def change
    create_table :pension_alimentaires do |t|
      t.string :numero_dossier
      t.string :nom
      t.string :prenom
      t.string :adresse
      t.string :telephone
      t.string :email
      t.float :montant
      t.datetime :date_naissance
      t.datetime :date_jouissance
      t.string :numero_allocataire
      t.string :commentaire
      t.integer :etat
      t.datetime :valider_le
      t.integer :valider_par_id
      t.integer :ajouter_par_id
      t.integer :gest_allocataire_id
      t.datetime :affecter_le
      t.datetime :traite_le

      t.timestamps
    end
  end
end