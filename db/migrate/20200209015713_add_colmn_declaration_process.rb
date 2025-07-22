class AddColmnDeclarationProcess < ActiveRecord::Migration[5.2]
  def change
    add_column :declarations, :process_flow_id , :integer, default: 0, limit: 8

    add_column :declarations, :form_id , :integer, default: 0, limit: 8
  end
end
