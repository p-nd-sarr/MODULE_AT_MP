class Immatriculation < ApplicationRecord
  self.table_name = 'immatriculation_societes'

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
      soumis: 2,
      valide: 3
  }.freeze

  enum etat: ETAT

  TYPE_PIECE = {
      cdao: 1,
      nin: 2,
      pass: 3,
      conc: 4
  }.freeze

  enum type_pieces: TYPE_PIECE

  STATUT = {
      adm: 1,
      acfie: 2,
      acfis: 3,
      avfie: 4,
      aviecacss: 5,
      avfiecaipres: 6,
      iesv: 7,
      pending: 8,
      autre: 9
  }.freeze

  enum statut_demande: STATUT

  has_many :document_immatriculations
  has_many :salarie_immatriculations
  belongs_to :user

  belongs_to :admin_type_employeur, optional: true, :class_name => 'Admin::TypeEmployeur', foreign_key: :type_employeur
  belongs_to :admin_statut_juridique, optional: true, :class_name => 'Admin::StatutJuridique', foreign_key: :statut_juridique
  belongs_to :admin_activite_principale, optional: true, :class_name => 'Admin::ActivitePrincipale', foreign_key: :activite_principale
  belongs_to :admin_secteur_activite, optional: true, :class_name => 'Admin::SecteurActivite', foreign_key: :secteur_activite
  #belongs_to :admin_country, :class_name => 'Admin::Country', foreign_key: :nationality

  belongs_to :reprise_region, optional: true, :class_name => 'Admin::Region', foreign_key: :region
  belongs_to :reprise_departement, optional: true, :class_name => 'Admin::Departement', foreign_key: :departement
  belongs_to :reprise_ville, optional: true, :class_name => 'Admin::Ville', foreign_key: :ville
  belongs_to :reprise_commune, optional: true, :class_name => 'Admin::Commune', foreign_key: :commune
  belongs_to :reprise_quartier, optional: true, :class_name => 'Admin::Quartier', foreign_key: :quartier

  def adresse
   " test"
  end

  def mobile_number
    if mobileNumber.nil?
      ''
    end
    if mobileNumber.start_with?('00221')
      return mobileNumber.gsub('00221', '')
    end
    if mobileNumber.start_with?('221')
      mobileNumber.gsub('221', '')
    end
  end

  def infos_societe_valide!(est_valide = true)
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
        regType: 'BVOLN', employerType: admin_type_employeur.code.upcase, typeEtablissement: type_etablissement.upcase,
        employerName: raison_sociale, hqId: 'GE', nineaNumber: ninea, ninetNumber: ninet, companyOriginId: '',
        legalStatus: admin_statut_juridique.code, taxId: code_identification_fiscale, taxIdDate: date_identification_fiscale.strftime("%Y-%m-%d"), tradeRegisterNumber: registre_commerce, tradeRegisterDate: date_identification_rc.strftime("%Y-%m-%d")
    }
  end

  def infos_employer_pub_para
    {
        regType: 'BVOLN', employerType: admin_type_employeur.code.upcase, typeEtablissement: type_etablissement.upcase, estType: 'HOP',
        employerName: raison_sociale, hqId: 'GE', nineaNumber: ninea, arretOuDecret: 'DECRET', dateArreteOuDecret: '',
        companyOriginId: ''
    }
  end

  def infos_etat_civil
    {
        dateOfInspection: embauche_employer, dateOfFirstHire: embauche_employer, shortName: sigle,
        businessSector: admin_secteur_activite.description, mainLineOfBusiness: admin_activite_principale.description,
        atRate: '', noOfWorkersInGenScheme: effectif_employe, noOfWorkersInBasicScheme: effectif_cadre,
        country: 'SEN', region: reprise_region.designation, department: reprise_departement.designation,
        arondissement: reprise_ville.designation, commune: reprise_commune.designation,
        qartier: reprise_quartier.designation, address: adresse, postboxNo: '', telephone: mobile_number, email: email,
        website: '', zoneCss: '', zoneIpres: '', sectorCss: '', sectorIpres: '', agencyCss: '', agencyIpres: ''
    }
  end

  def infos_adress
    {
        region: reprise_region.designation, department: reprise_departement.designation,
        arondissement: reprise_ville.designation, commune: reprise_commune.designation,
        qartier: reprise_quartier.designation, address: adresse
    }
  end

  def create_employeur
    if soumis?
      Psrm::Employeur.create(
          fhnum: "",
          ancien_num_ipres: "",
          ancien_num_css: "",
          fhrsoc: raison_sociale,
          activite_prinicipal: "",
          fhbp: "",
          fhadr: adresse,
          fhtel: "",
          fheffa: date_immatriculation,
          taux_at: taux_at,
          solde_pf: 0,
          solde_at: 0,
          solde_ve: 0,
          solde_total: 0,
          statut: "",
          ancien_statut_ipres: "",
          ancien_statut_css: ""

      )
    end
  end
end
