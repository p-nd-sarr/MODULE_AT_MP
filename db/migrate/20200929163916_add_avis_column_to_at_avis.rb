class AddAvisColumnToAtAvis < ActiveRecord::Migration[5.2]
  def change
    add_column :at_avis, :avis, :integer, default: 1
  end
end
