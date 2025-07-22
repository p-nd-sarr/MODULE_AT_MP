class AddFieldsToHistorique < ActiveRecord::Migration[5.2]
  def change
    add_column :historiques, :field, :string
    add_column :historiques, :new_value, :string
    add_column :historiques, :old_value, :string
  end
end
