class CreateRegularisationImpaye < ActiveRecord::Migration[5.2]
  def change
    create_table :regularisation_impayes do |t|
      t.references :regularisation_pension
      t.references :ordre_paiement
      t.string :numero_allocataire
      t.string :numero_ordre, null: false, limit: 20
      t.integer :etat, default: 0, null: false
      t.integer :periode 
      t.integer :numero_periode 
      t.string :annee
      t.string :code_operations
      t.integer :montant
      t.string :dossier_type
      t.timestamps
    end
  end
end
