class AddSalaireReferenceToAdminBareme < ActiveRecord::Migration[5.2]
  def change
    add_column :admin_baremes, :salaire_reference, :float, null: false
  end
end
