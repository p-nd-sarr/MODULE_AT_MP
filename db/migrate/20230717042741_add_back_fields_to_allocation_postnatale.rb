class AddBackFieldsToAllocationPostnatale < ActiveRecord::Migration[5.2]
  def change
    add_column :allocation_postnatales, :retourne_par_id, :integer
    add_column :allocation_postnatales, :date_retour, :date
  end
end
