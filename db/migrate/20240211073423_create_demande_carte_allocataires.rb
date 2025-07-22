class CreateDemandeCarteAllocataires < ActiveRecord::Migration[5.2]
  def change
    create_table :demande_carte_allocataires do |t|
      t.references :user, foreign_key: true
      t.references :allocataire, foreign_key: true
      t.string :numero_document
      t.integer :agence_enregistrement_id
      t.string :nom
      t.string :prenom
      t.date :date_naissance
      t.string :nin
      t.string :email
      t.string :adresse
      t.integer :agence_retrait_id
      t.string :telephone

      t.timestamps
    end
  end
end
