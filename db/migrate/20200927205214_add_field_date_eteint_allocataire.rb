class AddFieldDateEteintAllocataire < ActiveRecord::Migration[5.2]
  def change
    add_column :allocataires, :date_eteint, :datetime
  end
end
