class Employer::ImmatriculationMaintiensController < Employer::ApplicationController

  before_action :init_entity_list

  def index
    @immatriculation = current_user.immatriculation
    @representant = current_user.representant_legal

    @salaries = current_user.salarie_immatriculations.page(params[:page]).per(10)

    if @immatriculation.nil?
      type_employeur = Admin::TypeEmployeur.find_by_code('MAIN')
      @immatriculation = Immatriculation.new
      @immatriculation.admin_type_employeur = type_employeur
      @immatriculation.raison_sociale = current_user.nom
      @immatriculation.ninea = current_user.ninea
    end

    if @representant.nil?
      @representant = RepresentantLegal.new
    end

    @document_immatriculation = DocumentImmatriculation.new
    @salarie_immatriculation = SalarieImmatriculation.new

    @active_societe = 'active'

    calcul_pourcentage()
  end

  def new
    @immatriculation = Immatriculation.new

    @representant = RepresentantLegal.new

  end

  def show
    #show
  end

  def create
    @immatriculation = Immatriculation.new(immatriculation_params)

    @immatriculation.user = current_user
    if @immatriculation.save
      redirect_to [:employer, 'immatriculation_maintiens'], notice: "Immatriculation créée avec succès."
    else
      puts @immatriculation.errors.full_messages
      flash[:error] = @immatriculation.errors.full_messages
      render :index
    end
  end

  def edit
    #edit
  end

  def update
    @immatriculation = Immatriculation.find(params[:id])
    if @immatriculation.update(immatriculation_params)

      immatriculation = current_user.immatriculation
      immatriculation.salarie_valide!(false)

      redirect_to [:employer, 'immatriculation_maintiens'], notice: "Immatriculation modifié avec succés."
    else
      flash[:error] = @immatriculation.errors.full_messages
      render :index
    end
  end

  def valider_infos_societe
    @immatriculation = current_user.immatriculation

    @immatriculation.infos_societe_valide!
    redirect_to [:employer, 'immatriculation_maintiens'], notice: 'Information sur la société validée.'
  end

  def valider_salarie
    @immatriculation = current_user.immatriculation
    @immatriculation.salarie_valide!
    redirect_to [:employer, 'immatriculation_maintiens'], notice: 'Information sur les salariés validée.'
  end

  def valider_representant
    @immatriculation = current_user.immatriculation
    @immatriculation.representant_valide!
    @immatriculation.documents_valide!
    @immatriculation.salarie_valide!
    @immatriculation.infos_societe_valide!
    redirect_to [:employer, 'immatriculation_maintiens'], notice: 'Information sur le représentant validée.'
  end

  def valider_documents
    @immatriculation = current_user.immatriculation
    @document_immatriculation = current_user.document_immatriculations
    if @document_immatriculation.size > 0
      @immatriculation.documents_valide!
      redirect_to [:employer, 'immatriculation_maintiens'], notice: 'Information sur les documents validée.'

    else
      flash[:error] = 'Pas de Document ajouté.'
      redirect_to [:employer, 'immatriculation_maintiens']
    end
  end

  def soumettre_demande
    @immatriculation = current_user.immatriculation

    call_web_service_immatriculation

    redirect_to [:employer, 'immatriculation_maintiens'], notice: 'La demande est soumise.'
  end

  def download_template
    send_file("#{Rails.root}/public/template_salarie.csv")
  end

  def load_entities
    init_entity_list
  end

  def calcul_pourcentage
    @pourcentage = 0
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

  private

  def soumission_demande_params
    params.require(:immatriculation).permit(:date_ouverture)
  end

  def immatriculation_params
    params.require(:immatriculation).permit(:type_immatriculation, :raison_sociale, :type_etablissement, :ninea, :ninet, :registre_commerce,
                                            :statut_juridique, :code_identification_fiscale, :date_immatriculation, :date_identification_fiscale, :date_identification_rc,
                                            :date_ouverture, :siege_social, :activite_principale, :secteur_activite, :email, :adresse, :mobileNumber,
                                            :region, :departement, :ville, :commune, :quartier, :sigle, :effectif_employe, :effectif_cadre, :embauche_employer, :embauche_cadre)
  end

  def call_web_service_immatriculation
    require 'savon'

    namespaces = {
        "xmlns:main" => "http://oracle.com/MAINT-AFF_INBOUND.xsd",
    }

    logger.info "-----> call operations WS"
    # create a client for the service
    client = Savon.client(wsdl: 'http://192.168.125.23:6500/ouaf/XAIApp/xaiserver/MAINT-AFF_INBOUND?wsdl',
                          #client = Savon.client(wsdl: '#{WS_IMM_BASE_PATH}/ouaf/XAIApp/xaiserver/MAINT-AFF_INBOUND?wsdl',
                          basic_auth: WS_IMM_AUTH,
                          :raise_errors => true, # false if you don't want to see exceptions
                          pretty_print_xml: true,
                          logger: Rails.logger,
                          log_level: :debug,
                          log: true,
                          namespace_identifier: :main,
                          element_form_default: :qualified,
                          env_namespace: :soapenv,
                          namespaces: namespaces,
                          convert_request_keys_to: :none)

    response = nil

    puts " -----> operations : #{client.operations}"

    immatriculation = current_user.immatriculation
    representant = current_user.representant_legal

    information_generales = get_information_generales()

    begin
      response = client.call(:maint_aff_inbound) do
        message(input: {
            registrationFormInfos: {receiveDate: '2020-01-21', documentLocator: 'TEST_URL'},
            informationsGenerales: information_generales,
            infosSupplementaires: representant.infos_adress
        })

      end

    rescue Savon::SOAPFault => error
      begin
        detail = error.to_hash[:fault][:detail][:fault][:server_message][:text]
        puts detail
        immatriculation.message = detail
        immatriculation.save
      rescue StandardError => e
        puts e.message
      end
    rescue Savon::HTTPError => error
      puts error.http.code
    rescue Savon::Error => soap_fault
      puts "Error: #{soap_fault}\n"
    rescue Net::ReadTimeout => error
      puts " Net::ReadTimeout #{ error.to_s}"
    end

    if !response.nil? and response.success?

      immatriculation.process_flow_id = response.to_hash[:immatriculation_inbound][:output][:process_flow_id]
      immatriculation.employer_registration_form_id = response.to_hash[:immatriculation_inbound][:output][:employer_registration_form_id]
      immatriculation.employee_registration_form_id = response.to_hash[:immatriculation_inbound][:output][:employee_registration_form_id]

      immatriculation.zoneCss = response.to_hash[:immatriculation_inbound][:output][:zone_css]
      immatriculation.zoneIpres = response.to_hash[:immatriculation_inbound][:output][:zone_ipres]
      immatriculation.sectorCss = response.to_hash[:immatriculation_inbound][:output][:sector_css]
      immatriculation.sectorIpres = response.to_hash[:immatriculation_inbound][:output][:sectoricpres]
      immatriculation.taux_at = response.to_hash[:immatriculation_inbound][:output][:taux_at]


      immatriculation.etat = :soumis
      immatriculation.date_soumission = DateTime.now
      immatriculation.save!

    end

  end

  def get_information_generales
    representant = current_user.representant_legal

    information_generales = {typeImmatriculation: 'CMPL', typeEmployeur: 'MAIN', recherche: '', nom: representant.last_name, prenom: representant.first_name, nationalite: representant.nationality, typePieceIdentite: representant.type_of_identity.upcase,
                             nin: representant.identity_number, nincedeao: representant.nin_cedeo, numIdNationale: '', dateDelivrance: representant.issued_date, dateExpiration: representant.expiry_date, dateDeNaissance: representant.birthdate, paysDeNaissance: representant.admin_place_of_birth.code.upcase,
                             villeDeNaissance: representant.admin_place_of_birth.code.upcase, nbrAnneeCot: 8, telephoneFixe: '', numeroMobile: representant.mobile_number, email: representant.email}

    return information_generales
  end

end