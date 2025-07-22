class AddMotifConvocationToAtCompte < ActiveRecord::Migration[5.2]
  def change
    add_column :at_decomptes, :motif_convocation, :string
    add_column :at_decomptes, :date_convocation, :datetime
    add_column :at_decomptes, :convoquer_par_id, :integer
  end
end
