class AddInfosBanqueToAllocataire < ActiveRecord::Migration[5.2]
  def change
    add_column :allocataires, :admin_banque_agence_id, :integer
    add_column :allocataires, :compte_bancaire_cle_rib, :string, limit: 2
    change_column :allocataires, :compte_bancaire_numero_compte, :string, limit: 12

    remove_column :allocataires, :compte_bancaire_code_banque, :string
    remove_column :allocataires, :compte_bancaire_code_guichet, :string
  end
end
