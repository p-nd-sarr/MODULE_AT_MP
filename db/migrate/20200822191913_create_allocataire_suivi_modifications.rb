class CreateAllocataireSuiviModifications < ActiveRecord::Migration[5.2]
  def change
    create_table :allocataire_suivi_modifications do |t|
      t.references :allocataire, null: false
      t.references :dossier_revision, polymorphic: true, null: true, index: { name: 'index_allocataire_suivi_modifications_on_dr_type_and_dr_id' }
      t.string :commentaire, null: false
      t.datetime :date_validation, null: false
      t.boolean :impacte_montant_paiement, null: false

      t.timestamps
    end
  end
end
