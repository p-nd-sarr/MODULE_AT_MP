class AddColummnEtaToMaintienPrestation < ActiveRecord::Migration[5.2]
  def change
    add_column :maintien_prestations, :etat, :integer
  end
end
