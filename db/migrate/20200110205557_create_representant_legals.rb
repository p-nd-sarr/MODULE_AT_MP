class CreateRepresentantLegals < ActiveRecord::Migration[5.2]
  def change
    create_table :representant_legals do |t|
      t.string :last_name
      t.string :first_name
      t.date :birthdate
      t.integer :nationality
      t.integer :nin
      t.integer :place_of_birth
      t.string :city_of_birth
      t.integer :type_of_identity
      t.integer :identity_number
      t.integer :nin_cedeo
      t.date :issued_date
      t.date :expiry_date
      t.integer :region
      t.integer :departement
      t.integer :ville
      t.integer :commune
      t.integer :quartier
      t.string :address
      t.string :land_line_number
      t.string :mobile_number
      t.string :email

      t.references :user
      t.references :immatriculation_societe_prive

      t.timestamps
    end
  end
end
