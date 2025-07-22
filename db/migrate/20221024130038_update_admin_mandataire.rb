class UpdateAdminMandataire < ActiveRecord::Migration[5.2]
  def change
    remove_reference :admin_mandataires, :employeur, index: true
    add_column :admin_mandataires, :numero_employeur, :string, null: false
  end
end