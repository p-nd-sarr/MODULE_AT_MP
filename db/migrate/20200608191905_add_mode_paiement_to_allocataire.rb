class AddModePaiementToAllocataire < ActiveRecord::Migration[5.2]
  def change
    add_column :allocataires, :mode_paiement, :string
    add_column :allocataires, :compte_bancaire_nom_banque, :string
    add_column :allocataires, :compte_bancaire_code_banque, :string
    add_column :allocataires, :compte_bancaire_code_guichet, :string
    add_column :allocataires, :compte_bancaire_numero_compte, :string
  end
end
