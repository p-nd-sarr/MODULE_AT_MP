class AddEstReprisToGrossesse < ActiveRecord::Migration[5.2]
  def change
    add_column :grossesses, :est_repris, :boolean, default: false
  end
end
