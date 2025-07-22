class AddEstEnceinteToConjoint < ActiveRecord::Migration[5.2]
  def change
    add_column :conjoints, :est_enceinte, :boolean, default: false
  end
end
