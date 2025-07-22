class CreateBienPersConjoints < ActiveRecord::Migration[5.2]
  def change
    create_table :bien_pers_conjoints do |t|
      t.references :liquidation_retraite_france, foreign_key: true
      t.string :description
      t.float :valeur_actuelle
      t.string :situation_departement
      t.string :lieu_imposition
      t.float :revenu_cadastral

      t.timestamps
    end
  end
end
