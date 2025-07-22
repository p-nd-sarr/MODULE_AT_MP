class ChangeTypeNumberRegistreToEnfant < ActiveRecord::Migration[5.2]
  def change
    change_column :enfants, :numero_registre, :string
  end
end
