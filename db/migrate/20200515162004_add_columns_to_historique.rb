class AddColumnsToHistorique < ActiveRecord::Migration[5.2]
  def change
    add_column :historiques, :allocataire_id, :integer
    add_column :historiques, :user_id, :integer
  end
end
