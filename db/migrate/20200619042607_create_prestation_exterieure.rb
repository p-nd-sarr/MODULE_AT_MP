class CreatePrestationExterieure < ActiveRecord::Migration[5.2]
  def self.up
    drop_table :prestation_exterieures, if_exists: true

    create_table :prestation_exterieures do |t|
      t.string :prenom
      t.string :nom
      t.string :nom_jeune_fille
      t.integer :sexe_salarie
      t.date :date_naissance
      t.string :lieu_naissance
      t.string :nin_salarie
      t.integer :situation_matrimoniale_salarie
      t.integer :nationalite_salarie
      t.string :adresse_pays_origine
      t.string :adresse_pays_emploi
      t.timestamps
    end
  end

  def self.down
    drop_table :prestation_exterieures
  end
end
