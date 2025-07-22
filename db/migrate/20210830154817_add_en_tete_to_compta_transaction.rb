class AddEnTeteToComptaTransaction < ActiveRecord::Migration[5.2]
  def change
    add_column :compta_transactions, :en_tete, :boolean, default: true, null: false
  end
end
