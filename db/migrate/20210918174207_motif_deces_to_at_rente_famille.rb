class MotifDecesToAtRenteFamille < ActiveRecord::Migration[5.2]
  def change
    add_column :at_rente_familles, :motif_deces, :string
  end
end
