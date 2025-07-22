class AddRevisionCarriere < ActiveRecord::Migration[5.2]
  def change

    add_column :carrieres, :revision_pension_id, :integer, :default => 0

  end
end
