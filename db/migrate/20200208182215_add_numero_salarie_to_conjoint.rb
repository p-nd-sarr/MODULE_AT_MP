class AddNumeroSalarieToConjoint < ActiveRecord::Migration[5.2]
  def change
    add_column :conjoints, :est_salarie, :boolean
    add_column :conjoints, :numero_salarie, :string
  end
end
