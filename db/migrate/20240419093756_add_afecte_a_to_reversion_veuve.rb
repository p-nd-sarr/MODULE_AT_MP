class AddAfecteAToReversionVeuve < ActiveRecord::Migration[5.2]
  def change
    add_column :reversion_veuves, :affecte_a_id, :integer
  end
end
