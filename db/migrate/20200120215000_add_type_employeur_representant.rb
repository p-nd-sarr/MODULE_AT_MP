class AddTypeEmployeurRepresentant < ActiveRecord::Migration[5.2]
  def change
    add_column :representant_legals , :type_employeur, :string

  end
end
