class AddMotifRejetAllocataire < ActiveRecord::Migration[5.2]
  def change
    add_column :allocataires, :motif_rejet, :string
    add_column :allocataires, :traite_le, :datetime
    add_column :allocataires, :traite_par_id, :integer
  end
end
