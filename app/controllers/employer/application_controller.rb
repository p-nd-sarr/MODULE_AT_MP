class Employer::ApplicationController < ApplicationController
  before_action :authenticate_user!
  before_action :only_employer!

  before_action :set_employeur

  def init_entity_list
    if @regions.nil?
      @regions = Admin::Region.order(:designation)
      @departements = Admin::Departement.where(admin_region_id: 1).order(:designation)
      @villes = Admin::Ville.where(admin_departement_id: 1).order(:designation)
      @communes = Admin::Commune.where(admin_ville_id: 1).order(:designation)
      @quartiers = Admin::Quartier.order(:designation)
      @secteurs = Admin::SecteurActivite.order(:description)
      @activites = Admin::ActivitePrincipale.order(:description)
      @type_employeurs = Admin::TypeEmployeur.all
      @statut_juridiques = Admin::StatutJuridique.all
      @conventions = Admin::ConventionCollective.all
      @professions = Admin::Profession.all
      @pays = Admin::Country.all.order(:description)
    end
  end

  def calcul_pourcentage
    @pourcentage =0
    if @immatriculation != nil
      if @immatriculation.etat_civil_demandeur_valide
        @pourcentage += 25
      end

      if @immatriculation.representant_valide
        @pourcentage += 25
      end

      if @immatriculation.salarie_valide
        @pourcentage += 25
      end

      if @immatriculation.documents_valide
        @pourcentage += 25
      end
    end
  end


  def load_adresse
    if( !params[:region].nil? )
      @resources = Admin::Departement.where(admin_region_id: params[:region])
      render 'employer/immatriculations/lists/departement', :layout => false
    elsif( !params[:departement].nil? )
      @resources = Admin::Ville.where(admin_departement_id: params[:departement])
      render 'employer/immatriculations/lists/ville', :layout => false
    elsif( !params[:ville].nil? )
      @resources = Admin::Commune.where(admin_ville_id: params[:ville])
      render 'employer/immatriculations/lists/commune', :layout => false
    elsif( !params[:commune].nil? )
      @resources = Admin::Quartier.where(admin_commune_id: params[:commune])
      render 'employer/immatriculations/lists/quartier', :layout => false
    end
  end


  def infos_employer
    {
        regType: 'BVOLN', employerType: admin_type_employeur.code.upcase, typeEtablissement: type_etablissement.upcase,
        employerName: raison_sociale, hqId: 'GE', nineaNumber: ninea, ninetNumber: ninet, companyOriginId: '',
        legalStatus: admin_statut_juridique.code, taxId: code_identification_fiscale, taxIdDate: date_identification_fiscale.strftime("%Y-%m-%d"), tradeRegisterNumber: registre_commerce, tradeRegisterDate: date_identification_rc.strftime("%Y-%m-%d")
    }
  end

  def get_salaries_to_json
    salaries = SalarieImmatriculation.where(user_id: current_user.id).actif
    salaries_json = []
    salaries.each do |salarie|
      salarie_json = {
          rechercheEmploye: '', nomEmploye: salarie.nom, prenomEmploye: salarie.prenom, sexe: salarie.sexe.nil? ? "" : salarie.sexe.upcase, etatCivil: salarie.etat_civil.nil? ? "" : salarie.etat_civil.upcase, dateNaissance: salarie.date_naissance,
          numRegNaiss: salarie.numero_registre_naiss, nomPere: salarie.nom_pere, prenomPere: salarie.prenom_pere, nomMere: salarie.nom_mere,
          prenomMere: salarie.prenom_mere, nationalite: salarie.admin_nationalite.code, typePieceIdentite: salarie.type_piece.nil? ? "" : salarie.type_piece.upcase, nin: salarie.nin, ninCedeao: salarie.nin_cedeao, numPieceIdentite: salarie.numero_piece, delivreLe: salarie.date_delivrance,
          LieuDelivrance: salarie.admin_pays_naissance.code, expireLe: salarie.date_expiration, villeNaissance: salarie.ville_naissance.nil? ? "DAKAR" : salarie.ville_naissance, paysNaissance: salarie.admin_pays_naissance.code, employeurPrec: salarie.employer_precedent,
          pays: salarie.admin_pays.nil? ? "SEN" : salarie.admin_pays.code, region: salarie.reprise_region.designation, departement: salarie.reprise_departement.designation, arrondissement: salarie.reprise_ville.designation,
          commune: salarie.reprise_commune.designation, quartier: salarie.reprise_quartier.designation, adresse: salarie.adresse, boitePostale: salarie.boite_postal, typeMouvement: salarie.type_mouvement,
          natureContrat: salarie.nature_contrat.nil? ? "" : salarie.nature_contrat.upcase, dateDebutContrat: salarie.date_debut_contrat, dateFinContrat: salarie.date_fin_contrat,
          profession: salarie.admin_profession.code, emploi: salarie.emploi, nonCadre: salarie.est_non_cadre, ouiCadre: salarie.est_cadre, conventionApplicable: salarie.admin_convention_collective.code,
          salaireContractuel: salarie.salaire_contractuel, tempsTravail: salarie.temps_travail.nil? ? "" :  salarie.temps_travail.upcase, categorie: salarie.categorie
      }
      salaries_json << salarie_json
    end
    salaries_json
  end


  def set_employeur
    puts "====> set_employeur"
    @employeur = Psrm::Employeur.find_by(ancien_num_ipres: current_user.num_ipres)

    puts "===> employeur = #{@employeur}"
  end

end