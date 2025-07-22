class AddAttributaireAndSubrogationToComptaTransaction < ActiveRecord::Migration[5.2]
  def change
    add_column :compta_transactions, :est_attributaire, :boolean, null: false, default: false
    add_column :compta_transactions, :par_subrogation, :boolean, null: false, default: false
    add_column :compta_transactions, :id_reel_allocataire, :string
    add_column :compta_transactions, :nom_reel_allocataire, :string
    add_column :compta_transactions, :prenom_reel_allocataire, :string
  end
end
