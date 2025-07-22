class ChangeTypeNumberRegistreToConjoint < ActiveRecord::Migration[5.2]
  def change
    change_column :conjoints, :numero_registre, :string
  end
end
