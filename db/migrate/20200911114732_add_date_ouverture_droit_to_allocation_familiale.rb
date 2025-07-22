class AddDateOuvertureDroitToAllocationFamiliale < ActiveRecord::Migration[5.2]
  def change
    add_column :allocation_familiales, :date_ouverture_droit, :date
  end
end
