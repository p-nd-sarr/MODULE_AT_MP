class AddActivatedByToUser < ActiveRecord::Migration[5.2]
  def change
    add_column :users, :activated_by_id, :integer
  end
end
