class CreateAdminJourOuvrableAnnuels < ActiveRecord::Migration[5.2]
  def change
    create_table :admin_jour_ouvrable_annuels do |t|
      t.string :mois
      t.integer :mois_en_chiffre
      t.integer :nombre_jour_ouvrable

      t.timestamps
    end
  end
end
