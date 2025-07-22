class AddColumnMotifretourToRevisionPension < ActiveRecord::Migration[5.2]
  def change
    add_column :revision_pensions, :motif_retour, :text
  end
end
