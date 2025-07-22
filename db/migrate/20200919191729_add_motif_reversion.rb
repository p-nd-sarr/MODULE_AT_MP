class AddMotifReversion < ActiveRecord::Migration[5.2]
  def change
    add_column :reversion_veuves, :motif, :string
    add_column :reversion_veuves, :telephone, :string
    add_column :reversion_veuves, :email, :string
  end
end
