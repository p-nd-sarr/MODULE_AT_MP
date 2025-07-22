class AddColumnLienParenteInCafEnfant < ActiveRecord::Migration[5.2]
  def change
    add_column :caf_enfants, :lien_parente, :integer
  end
end
