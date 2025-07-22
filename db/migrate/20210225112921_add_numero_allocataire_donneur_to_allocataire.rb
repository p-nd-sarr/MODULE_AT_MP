class AddNumeroAllocataireDonneurToAllocataire < ActiveRecord::Migration[5.2]
  def change
    add_column :allocataires, :numero_allocataire_donneur, :string, limit: 20
    add_index :allocataires, :numero_allocataire_donneur
  end
end
