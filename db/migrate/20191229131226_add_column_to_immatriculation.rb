class AddColumnToImmatriculation < ActiveRecord::Migration[5.2]
  def change

    add_column :immatriculations, :nom, :string
    add_column :immatriculations, :prenom, :string
    add_column :immatriculations, :website, :string
    add_column :immatriculations, :zoneCss, :string
    add_column :immatriculations, :zoneIpres, :string
    add_column :immatriculations, :sectorCss, :string
    add_column :immatriculations, :sectorIpres, :string
    add_column :immatriculations, :agencyCss, :string
    add_column :immatriculations, :agencyIpres, :string
    add_column :immatriculations, :lastName, :string
    add_column :immatriculations, :firstName, :string
    add_column :immatriculations, :birthdate, :date
    add_column :immatriculations, :nationality, :string
    add_column :immatriculations, :nin, :integer
    add_column :immatriculations, :placeOfBirth, :string
    add_column :immatriculations, :cityOfBirth, :string
    add_column :immatriculations, :typeOfIdentity, :string
    add_column :immatriculations, :identityIdNumber, :string
    add_column :immatriculations, :ninCedeo, :integer
    add_column :immatriculations, :issuedDate, :string
    add_column :immatriculations, :expiryDate, :string
    add_column :immatriculations, :region_legal, :string
    add_column :immatriculations, :department_legal, :string
    add_column :immatriculations, :arondissement_legal, :string
    add_column :immatriculations, :commune_legal, :string
    add_column :immatriculations, :qartier_legal, :string
    add_column :immatriculations, :address_legal, :string
    add_column :immatriculations, :landLineNumber, :string
    add_column :immatriculations, :mobileNumber, :string
    add_column :immatriculations, :email, :string

    change_column :immatriculations, :type_immatriculation, :string
    change_column :immatriculations, :type_etablissement, :string
  end
end
