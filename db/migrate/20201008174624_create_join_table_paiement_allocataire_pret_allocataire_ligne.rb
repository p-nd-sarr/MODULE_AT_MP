class CreateJoinTablePaiementAllocatairePretAllocataireLigne < ActiveRecord::Migration[5.2]
  def change
    create_join_table :paiement_allocataires, :pret_allocataire_lignes do |t|
      t.index [:paiement_allocataire_id, :pret_allocataire_ligne_id], name: 'index_paiement_allocataires_pret_allocataire_lignes'
      # t.index [:pret_allocataire_ligne_id, :paiement_allocataire_id]
    end
  end
end
