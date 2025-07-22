class AddDateFinEnfantToAllocataire < ActiveRecord::Migration[5.2]
  def change
    add_column :allocataires, :enfant1_id, :integer
    add_column :allocataires, :enfant2_id, :integer
    add_column :allocataires, :enfant3_id, :integer
    add_column :allocataires, :date_fin_enfant1, :date
    add_column :allocataires, :date_fin_enfant2, :date
    add_column :allocataires, :date_fin_enfant3, :date
  end
end
