class AddColumnEmailToMandataire < ActiveRecord::Migration[5.2]
  def change
    add_column :admin_mandataires, :email, :string
  end
end
