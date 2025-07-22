class Employer::ImmatriculationsController < Employer::ApplicationController

  def index
    unless current_user.immatriculation.nil?
      immatriculation = current_user.immatriculation

      unless immatriculation.nil?
        case current_user.admin_type_employeur.code
        when "MAIN"
          redirect_to [:employer, 'immatriculation_maintiens']
        when "PVT"
          redirect_to [:employer, 'immatriculation_private_societes']
        when "NGO"
          redirect_to [:employer, 'immatriculation_ongs']
        when "ASSO"
          redirect_to [:employer, 'immatriculation_associations']
        when "INDV"
          redirect_to [:employer, 'immatriculation_individuelles']
        when "LIB"
          redirect_to [:employer, 'immatriculation_liberales']
        when "PROJ"
          redirect_to [:employer, 'immatriculation_projets']
        when "PUB_PARA"
          redirect_to [:employer, 'immatriculation_structure_publiques']
        when "REP_DIP"
          redirect_to [:employer, 'immatriculation_diplomatiques']
        when "TIND"
          redirect_to [:employer, 'immatriculation_independants']
        when "GIE"
          redirect_to [:employer, 'immatriculation_gies']
        when "DOM"
          redirect_to [:employer, 'immatriculation_domestiques']
        when "COOP"
          redirect_to [:employer, 'immatriculation_cooperatives']
        else
          redirect_to root_path
        end
      end

    end
  end

  def new
    @immatriculation = Immatriculation.new
    @immatriculation = init_info_immatriculation(@immatriculation)
  end

  def show
    @immatriculation = Immatriculation.find(params[:id])

    @document_immatriculation = DocumentImmatriculation.new
    @salarie_immatriculation = SalarieImmatriculation.new

    @salaries = SalarieImmatriculation.where(immatriculation_id: @immatriculation).page(params[:page]).per(10)
  end

  def update
    @immatriculation = Immatriculation.find(params[:id])
    if @immatriculation.update(immatriculation_params)

      immatriculation = current_user.immatriculation
      immatriculation.salarie_valide!(false)

      redirect_to [:employer, 'immatriculations'], notice: "Immatriculation modifié avec succés."
    else
      flash[:error] = @immatriculation.errors.full_messages
      render :index
    end
  end

  def edit
    @immatriculation = Immatriculation.find(params[:id])
  end

  def download_template
    send_file("#{Rails.root}/public/template_salarie.csv")
  end

  def valider_infos_societe
    @immatriculation = current_user.immatriculation
    @immatriculation.infos_societe_valide!
    redirect_to [:employer, 'immatriculations'], notice: 'Information sur la société validée.'
  end

  def load_activities

    if !params[:secteur].nil?
      @resources = Admin::ActivitePrincipale.where(admin_secteur_activite_id: params[:secteur])
      render 'employer/immatriculations/lists/activites', :layout => false
    end

  end

  def load_adresse
    if !params[:region].nil?
      @resources = Admin::Departement.where(admin_region_id: params[:region])
      render 'employer/immatriculations/lists/departement', :layout => false
    elsif !params[:departement].nil?
      @resources = Admin::Ville.where(admin_departement_id: params[:departement])
      @resources.each do |resource|
        puts "====> #{resource.designation}"
      end
      render 'employer/immatriculations/lists/ville', :layout => false
    elsif !params[:ville].nil?
      @resources = Admin::Commune.where(admin_ville_id: params[:ville])
      render 'employer/immatriculations/lists/commune', :layout => false
    elsif !params[:commune].nil?
      @resources = Admin::Quartier.where(admin_commune_id: params[:commune])
      render 'employer/immatriculations/lists/quartier', :layout => false
    end
  end

  private

  def ws_getstatut_immatriculation()
    require 'savon'

    namespaces = {
        "xmlns:cm" => "http://oracle.com/Cm-GetStatusDossierImmatriculation.xsd",
    }

    logger.info "-----> call operations WS"
    # create a client for the service
    client = Savon.client(wsdl: '#{WS_IMM_BASE_PATH}/ouaf/XAIApp/xaiserver/Cm-GetStatusDossierImmatriculation?wsdl',
                          basic_auth: WS_IMM_AUTH,
                          :raise_errors => true,
                          pretty_print_xml: true,
                          logger: Rails.logger,
                          log_level: :debug,
                          log: true,
                          namespace_identifier: :imm,
                          element_form_default: :qualified,
                          env_namespace: :soapenv,
                          namespaces: namespaces,
                          convert_request_keys_to: :none)

    response = nil

    immatriculation = current_user.immatriculation

    begin
      response = client.call(:Cm - GetStatusDossierImmatriculation) do
        message(input: {
            idDossierImmatriculation: immatriculation.process_flow_id
        })

      end

    rescue Savon::Error => error
      printf error.to_s
    rescue Savon::Error => soap_fault
      print "Error: #{soap_fault}\n"
    rescue Net::ReadTimeout => error
      printf error.to_s
    end

    if !response.nil? and response.success?

      @message_code = response.to_hash[:GetStatusDossierImmatriculation][:output][:codeStatus]
      @message_content = response.to_hash[:GetStatusDossierImmatriculation][:output][:description]

    end

  end


  def get_salaries_to_json
    salaries = SalarieImmatriculation.where(user_id: current_user.id).actif

    salaries_json = []
    salaries.each do |salarie|

      salarie_json = {rechercheEmploye: '', nomEmploye: salarie.nom, prenomEmploye: salarie.prenom, sexe: salarie.sexe.upcase, etatCivil: salarie.etat_civil.upcase, dateNaissance: salarie.date_naissance,
                      numRegNaiss: salarie.numero_registre_naiss, nomPere: salarie.nom_pere, prenomPere: salarie.prenom_pere, nomMere: salarie.nom_mere,
                      prenomMere: salarie.prenom_mere, nationalite: salarie.admin_nationalite, typePieceIdentite: salarie.type_piece.upcase, nin: salarie.nin, ninCedeao: salarie.nin_cedeao, numPieceIdentite: salarie.numero_piece, delivreLe: salarie.date_delivrance,
                      LieuDelivrance: salarie.admin_pays_naissance.code, expireLe: salarie.date_expiration, villeNaissance: salarie.ville_naissance, paysNaissance: salarie.admin_pays_naissance, employeurPrec: salarie.employer_precedent,
                      pays: salarie.admin_pays, region: salarie.reprise_region.designation, departement: salarie.reprise_departement.designation, arrondissement: salarie.reprise_ville.designation,
                      commune: salarie.reprise_commune.designation, quartier: salarie.reprise_quartier.designation, adresse: salarie.adresse, boitePostale: salarie.boite_postal, typeMouvement: salarie.type_mouvement,
                      natureContrat: salarie.nature_contrat.upcase, dateDebutContrat: salarie.date_debut_contrat, dateFinContrat: salarie.date_fin_contrat,
                      profession: salarie.admin_profession.code, emploi: salarie.emploi, nonCadre: salarie.est_non_cadre, ouiCadre: salarie.est_cadre, conventionApplicable: salarie.admin_convention_collective.code,
                      salaireContractuel: salarie.salaire_contractuel, tempsTravail: salarie.temps_travail.upcase, categorie: salarie.categorie
      }
      salaries_json << salarie_json

    end

    return salaries_json
  end


  def immatriculation_params
    params.require(:immatriculation).permit(:type_immatriculation, :raison_sociale, :type_etablissement, :ninea, :ninet, :registre_commerce,
                                            :statut_juridique, :code_identification_fiscale, :date_immatriculation, :date_identification_fiscale, :date_identification_rc,
                                            :date_ouverture, :siege_social, :activite_principale, :secteur_activite, :email, :adresse, :mobileNumber,
                                            :region, :departement, :ville, :commune, :quartier, :sigle, :effectif_employe, :effectif_cadre, :embauche_employer, :embauche_cadre)
  end

end
