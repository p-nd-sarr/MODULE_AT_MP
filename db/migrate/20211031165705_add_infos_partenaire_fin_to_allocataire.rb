class AddInfosPartenaireFinToAllocataire < ActiveRecord::Migration[5.2]
  def change
    add_column :allocataires, :infos_paiement_id_bhs, :string, limit: 30
    add_column :allocataires, :infos_paiement_id_ccp, :string, limit: 30
    add_column :allocataires, :infos_paiement_libelle_ccp, :string, limit: 30
    add_column :allocataires, :infos_paiement_succursale_cncas, :string, limit: 30

    add_column :compta_transactions, :infos_paiement_id_bhs, :string, limit: 30
    add_column :compta_transactions, :infos_paiement_id_ccp, :string, limit: 30
    add_column :compta_transactions, :infos_paiement_libelle_ccp, :string, limit: 30
    add_column :compta_transactions, :infos_paiement_succursale_cncas, :string, limit: 30
  end
end
