class AddAvisMcValide < ActiveRecord::Migration[5.2]
  def change
    add_column :at_rechutes, :avis_mc_valide, :boolean
  end
end
