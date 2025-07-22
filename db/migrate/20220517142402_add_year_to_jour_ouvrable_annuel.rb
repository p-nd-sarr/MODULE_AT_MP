class AddYearToJourOuvrableAnnuel < ActiveRecord::Migration[5.2]
  def change
    add_column :admin_jour_ouvrable_annuels, :annee, :string
  end
end
