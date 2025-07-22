class AddEstReprisToCarriere < ActiveRecord::Migration[5.2]
  def change
    add_column :carrieres, :est_repris, :boolean, default: false
  end
end
