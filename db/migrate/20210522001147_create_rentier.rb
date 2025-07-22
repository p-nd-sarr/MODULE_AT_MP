class CreateRentier < ActiveRecord::Migration[5.2]
  def change
    create_table :rentiers do |t|
      t.string :numero_rentier, limit: 20, null: false
      t.string :nom, limit: 250
      t.string :prenom, limit: 250
      t.date :date_naissance, null: false
      t.string :lieu_naissance, null: false
      t.string :email
      t.string :sexe 
      t.string :telephone, limit: 30
      t.integer :etat
      t.integer :montant_net
      t.integer :prix_franc_rente
      t.integer :salaire_mensuel
      t.integer :salaire_annuel
      t.string :type_versement
      t.integer :taux_utile
      t.integer :age_conversion
      t.integer :taux_utile
      t.timestamps

    end
  end
end
