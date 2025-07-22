class AddColumnSexeToMandataire < ActiveRecord::Migration[5.2]
  def change
    add_column :admin_mandataires, :sexe, :integer
  end
end
