class ImmatriculationSocietePrive < ApplicationRecord
  TYPE_ETABLISSEMENT = {
      hdqt: 1,
      brnc: 2,
      cnst: 3
  }.freeze

  enum type_etablissement: TYPE_ETABLISSEMENT

  TYPE_IMMATRICULATION = {
      bvoln: 1,
      cmpl: 2
  }.freeze

  enum type_immatriculation: TYPE_IMMATRICULATION

  ETAT = {
      creation: 1,
      soumis: 2
  }.freeze

  enum etat: ETAT

  TYPE_PIECE = {
      cdao: 1,
      nin: 2,
      pass: 3,
      conc: 4
  }.freeze

  enum type_pieces: TYPE_PIECE

  has_many :document_immatriculations
  has_many :salarie_immatriculations
  has_one :representant_legal
  has_many  :declarations
  has_many  :moratoires
  belongs_to  :user

  belongs_to :admin_type_employeur, optional: true, :class_name => 'Admin::TypeEmployeur', foreign_key: :type_employeur
  belongs_to :admin_statut_juridique, optional: true, :class_name => 'Admin::StatutJuridique', foreign_key: :statut_juridique
  belongs_to :admin_activite_principale, optional: true, :class_name => 'Admin::ActivitePrincipale', foreign_key: :activite_principale
  belongs_to :admin_secteur_activite, optional: true, :class_name => 'Admin::SecteurActivite', foreign_key: :secteur_activite
  belongs_to :admin_country, optional: true, :class_name => 'Admin::Country', foreign_key: :nationality

  belongs_to :reprise_region, optional: true, :class_name => 'Admin::Region', foreign_key: :region
  belongs_to :reprise_departement, optional: true, :class_name => 'Admin::Departement', foreign_key: :departement
  belongs_to :reprise_ville, optional: true, :class_name => 'Admin::Ville', foreign_key: :ville
  belongs_to :reprise_commune, optional: true, :class_name => 'Admin::Commune', foreign_key: :commune
  belongs_to :reprise_quartier, optional: true, :class_name => 'Admin::Quartier', foreign_key: :quartier

  belongs_to :reprise_region_legal, optional: true, :class_name => 'Admin::Region', foreign_key: :region_legal
  belongs_to :reprise_departement_legal, optional: true, :class_name => 'Admin::Departement', foreign_key: :department_legal
  belongs_to :reprise_ville_legal, optional: true, :class_name => 'Admin::Ville', foreign_key: :arondissement_legal
  belongs_to :reprise_commune_legal, optional: true, :class_name => 'Admin::Commune', foreign_key: :commune_legal
  belongs_to :reprise_quartier_legal, optional: true, :class_name => 'Admin::Quartier', foreign_key: :qartier_legal

  def etat_civil_demandeur_valide!(est_valide = true)
    update(etat_civil_demandeur_valide: est_valide)
  end

  def documents_valide!(est_valide = true)
    update(documents_valide: est_valide)
  end

  def salarie_valide!(est_valide = true)
    update(salarie_valide: est_valide)
  end

  def representant_valide!(est_valide = true)
    update(representant_valide: est_valide)
  end

  def soumettre_demande!
    update(etat: :soumis, date_soumission: DateTime.now)
  end

  def pret_pour_soumission?
    etat_civil_demandeur_valide and documents_valide
  end

  def infos_employer
    {
        regType: 'BVOLN', employerType: 'PVT', typeEtablissement: type_etablissement.upcase, employerName: nom,
        hqId: 'GE', nineaNumber: '190022941', ninetNumber: ninet, companyOriginId: '', legalStatus: '', taxId: '',
        taxIdDate: '', tradeRegisterNumber: "BVOLN", tradeRegisterDate: ''
    }
  end

  def  infos_etat_civil
    {
        dateOfInspection: birthdate, dateOfFirstHire: birthdate, shortName: user.sigle,
        businessSector: admin_secteur_activite.description, mainLineOfBusiness: admin_activite_principale.description,
        atRate: '', noOfWorkersInGenScheme: effectif_employe, noOfWorkersInBasicScheme: effectif_cadre,
        region: reprise_region.designation, department: reprise_departement.designation,
        arondissement: reprise_ville.designation, commune: reprise_commune.designation,
        qartier: reprise_quartier.designation, address: adresse, postboxNo: '', telephone: telephone_employeur,
        email: email_employeur, website: '', zoneCss: '', zoneIpres: '', sectorCss: '', sectorIpres: '', agencyCss: '',
        agencyIpres: ''
    }
  end

  def infos_representant
    {
        legalRepPerson: '', lastName: user.nom, firstName: user.prenom, birthdate: birthdate,
        nationality: admin_country.code, nin: nin, placeOfBirth: placeOfBirth, cityOfBirth: placeOfBirth,
        typeOfIdentity: ImmatriculationSocietePrive.type_pieces.key(type_of_identity).upcase,
        identityIdNumber: identityIdNumber, ninCedeo: ninCedeo, issuedDate: birthdate, expiryDate: expiryDate,
        region: reprise_region_legal.designation, department: reprise_departement_legal.designation,
        arondissement: reprise_ville_legal.designation, commune: reprise_commune_legal.designation,
        qartier: reprise_quartier_legal.designation, address:  adresse, landLineNumber: '',
        mobileNumber: telephone_employeur, email: email_employeur
    }
  end
end