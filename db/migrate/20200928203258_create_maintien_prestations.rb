class CreateMaintienPrestations < ActiveRecord::Migration[5.2]
  def change
    create_table :maintien_prestations do |t|

      t.references :dossier_prestations, foreign_key: true
      t.integer :type
      t.date :date_demande_maintien
      t.date :date_arret_maintien

      t.timestamps
    end
  end
end
