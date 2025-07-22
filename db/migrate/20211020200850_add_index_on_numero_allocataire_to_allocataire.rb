class AddIndexOnNumeroAllocataireToAllocataire < ActiveRecord::Migration[5.2]
  def change
    add_index :allocataires, :numero_allocataire
    add_index :allocataires, :ipres_ancien_matric
    add_index :allocataires, :css_ancien_matric
  end
end
