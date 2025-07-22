class RemoveNumeroAffiliationFromAtConsolidation < ActiveRecord::Migration[5.2]
  def change

    remove_column :at_consolidations, :prenom, :string
    remove_column :at_consolidations, :nom, :string
    remove_column :at_consolidations, :date_naissance, :date
    remove_column :at_consolidations, :lieu_naissance, :string
    remove_column :at_consolidations, :numero_affiliation, :string
    remove_column :at_consolidations, :telephone, :string
    remove_column :at_consolidations, :adresse, :string
    remove_column :at_consolidations, :mode_paiement, :integer
    remove_column :at_consolidations, :compte_bancaire_nom_banque, :string
    remove_column :at_consolidations, :compte_bancaire_code_banque, :string
    remove_column :at_consolidations, :compte_bancaire_code_guichet, :string
    remove_column :at_consolidations, :compte_bancaire_numero_compte, :string
    remove_column :at_consolidations, :admin_banque_id, :integer
  end
end
