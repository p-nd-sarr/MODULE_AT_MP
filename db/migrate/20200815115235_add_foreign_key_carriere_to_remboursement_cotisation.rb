class AddForeignKeyCarriereToRemboursementCotisation < ActiveRecord::Migration[5.2]
  def change
    
    add_column :remboursement_cotisations, :carriere_id, :integer, unique: true
    add_column :remboursement_cotisations, :ajoute_par_id, :integer
    add_column :remboursement_cotisations, :ajouter_le, :date

    add_column :remboursement_cotisations, :valider_par_id, :integer
    add_column :remboursement_cotisations, :valider_le, :date
    

    add_column :remboursement_cotisations, :affecter_a, :integer
    add_column :remboursement_cotisations, :affecter_le, :date
  end
end
