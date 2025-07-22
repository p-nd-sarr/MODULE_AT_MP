class RepresentantLegal < ApplicationRecord
  TYPE_PIECE = {
      cdao: 0,
      nin: 1,
      pass: 2,
      conc: 3,
      autre: 4
  }.freeze

  enum type_of_identity: TYPE_PIECE

  belongs_to :user
  belongs_to :reprise_region, optional: true, :class_name => 'Admin::Region', foreign_key: :region
  belongs_to :reprise_departement, optional: true, :class_name => 'Admin::Departement', foreign_key: :departement
  belongs_to :reprise_ville, optional: true, :class_name => 'Admin::Ville', foreign_key: :ville
  belongs_to :reprise_commune, optional: true, :class_name => 'Admin::Commune', foreign_key: :commune
  belongs_to :reprise_quartier, optional: true, :class_name => 'Admin::Quartier', foreign_key: :quartier
  belongs_to :admin_country, optional: true, :class_name => 'Admin::Country', foreign_key: :nationality
  belongs_to :admin_place_of_birth, optional: true, :class_name => 'Admin::Country', foreign_key: :place_of_birth


  def format_mobile
    if mobile_number.nil?
      ''
    end
    if mobile_number.start_with?('00221')
      return mobile_number.gsub('00221', '')
    end
    if mobile_number.start_with?('221')
      mobile_number.gsub('221', '')
    end
  end

  def infos_representant
    {
        legalRepPerson: '', lastName: last_name, firstName: first_name, birthdate: birthdate,
        nationality: admin_country.code, nin: identity_number, placeOfBirth: "DAKAR", cityOfBirth: city_of_birth.nil? ? "" : city_of_birth,
        typeOfIdentity: type_of_identity.upcase, identityIdNumber: identity_number, ninCedeo: nin_cedeo.nil? ? "" : nin_cedeo,
        issuedDate: issued_date, expiryDate: expiry_date, region: reprise_region.designation,
        department: reprise_departement.designation, arondissement: reprise_ville.designation,
        commune: reprise_commune.designation, qartier: reprise_quartier.designation, address: address,
        landLineNumber: '', mobileNumber: format_mobile, email: email
    }
  end

  def infos_adress
    {
        region: reprise_region.designation, department: reprise_departement.designation,
        arrondissement: reprise_ville.designation, commune: reprise_commune.designation,
        quartier: reprise_quartier.designation, adresse: address, landLineNumber: '', mobileNumber: mobile_number,
        email: email
    }
  end
end