class AddMotifRejetAllocataireToDossierReversionSalary < ActiveRecord::Migration[5.2]
  def change
    add_column :dossier_reversion_salaries, :motif_rejet_allocataire, :string
    add_column :dossier_reversion_salaries, :rejet_allocataire_par_id, :integer
    add_column :dossier_reversion_salaries, :date_rejet_allocataire, :datetime
    
  end
end
