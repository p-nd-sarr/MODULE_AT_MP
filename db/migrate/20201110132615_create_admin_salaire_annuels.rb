class CreateAdminSalaireAnnuels < ActiveRecord::Migration[5.2]
  def change
    create_table :admin_salaire_annuels do |t|
      t.string :annee
      t.float :coefficient
      t.date :date_effet
      t.date :date_reval
      t.float :plancher
      t.float :plafond

      t.timestamps
    end
  end
end
