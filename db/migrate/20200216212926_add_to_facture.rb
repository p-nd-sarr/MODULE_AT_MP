class AddToFacture < ActiveRecord::Migration[5.2]
  def change
    add_column :factures, :date_debut , :date
    add_column :factures, :date_fin , :date
    add_column :factures, :montant_principal , :float
    add_column :factures, :majorations , :float
    add_column :factures, :dette , :float
    add_column :factures, :penalite , :float
    add_column :factures, :montant_verse , :float
    add_column :factures, :dette_input , :float
    add_column :factures, :montant_paye , :float
    add_column :factures, :type_facture , :string
    add_column :factures, :url , :string

  end
end
