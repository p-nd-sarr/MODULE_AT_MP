class AddDateAndAuthorsToOrdrePaiement < ActiveRecord::Migration[5.2]
  def change
    add_column :ordre_paiements, :paye_le, :datetime
    add_column :ordre_paiements, :impaye_le, :datetime
    add_column :ordre_paiements, :regularise_le, :datetime
    add_column :ordre_paiements, :paye_par_id, :integer
    add_column :ordre_paiements, :impaye_par_id, :integer
    add_column :ordre_paiements, :regularise_par_id, :integer
  end
end
