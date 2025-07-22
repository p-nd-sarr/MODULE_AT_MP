class Employer::HomeController < Employer::ApplicationController
  def index

    @ninea = current_user.ninea
    @nom = current_user.nom
    @num_immatriculation = current_user.num_immatriculation
    @num_css = current_user.num_css
    @num_ipres = current_user.num_ipres
    @telephone = current_user.telephone
    @email = current_user.email

    @document_immatriculation = DocumentLiquidationRetraite.new
    @salarie_immatriculation = SalarieImmatriculation.new

    @employeur = Psrm::Employeur.find_by(ancien_num_ipres: current_user.num_ipres)

    @immatriculation = current_user.immatriculation

    @class_active = 'active'

    @message_code = ''
    @message_content = ''
    @statut_demande = 0

    if @employeur.nil?
      @pourcentage = 0
    else
      @message_content = " Employé déja immatriculé"
      @pourcentage = 100
    end

    unless @immatriculation.nil?
      if (@immatriculation.process_flow_id != nil)
        ws_getstatut_immatriculation
      end

    end
  end

  def ws_getstatut_immatriculation
    require 'savon'

    namespaces = {
        "xmlns:cm" => "http://oracle.com/Cm-GetStatusDossierImmatriculation.xsd",
    }

    immatriculation = current_user.immatriculation

    # create a client for the service
    client = Savon.client(wsdl: "#{WS_IMM_BASE_PATH}/ouaf/XAIApp/xaiserver/Cm-GetStatusDossierImmatriculation?wsdl",
                          basic_auth: WS_IMM_AUTH,
                          :raise_errors => true, # false if you don't want to see exceptions
                          pretty_print_xml: true,
                          logger: Rails.logger,
                          log_level: :debug,
                          log: true,
                          namespace_identifier: :cm,
                          element_form_default: :qualified,
                          env_namespace: :soapenv,
                          namespaces: namespaces,
                          convert_request_keys_to: :none)

    response = nil

    begin
      response = client.call(:cm_get_status_dossier_immatriculation) do
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
      @message_code = response.to_hash[:cm_get_status_dossier_immatriculation][:output][:code_status]
      @message_content = response.to_hash[:cm_get_status_dossier_immatriculation][:output][:description]

      update_statut_demande
    end
  end

  def ws_document_immatriculation
    require 'savon'

    namespaces = {
        "xmlns:cmg" => "http://oracle.com/CmGetCertificatImmatriculation.xsd",
    }

    immatriculation = current_user.immatriculation
    # create a client for the service
    client = Savon.client(wsdl: "#{WS_IMM_BASE_PATH}/ouaf/XAIApp/xaiserver/CmGetCertificatImmatriculation?wsdl",
                          basic_auth: WS_IMM_AUTH,
                          :raise_errors => true, # false if you don't want to see exceptions
                          pretty_print_xml: true,
                          logger: Rails.logger,
                          log_level: :debug,
                          log: true,
                          namespace_identifier: :cmg,
                          element_form_default: :qualified,
                          env_namespace: :soapenv,
                          namespaces: namespaces,
                          convert_request_keys_to: :none)

    response = nil

    begin
      response = client.call(:cm_get_certificat_immatriculation) do
        message(input: {
            idDossier: immatriculation.process_flow_id
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
      @url = response.to_hash[:cm_get_certificat_immatriculation][:output][:url]
      puts "url : #{@url}"
      immatriculation.update_attribute(:url, @url)
    end
  end

  def update_statut_demande
    immatriculation = Immatriculation.where(user_id: current_user.id).last

    case @message_code
    when 'ADM'
      @pourcentage = 15
      @statut_demande = 1
    when 'ACFIE'
        @pourcentage = 15
        @statut_demande = 2
    when 'ACFIS'
      @pourcentage = 30
      @statut_demande = 3
    when 'AVFIE'
      @pourcentage = 45
      @statut_demande = 4
    when 'AVIECACSS'
      @pourcentage = 60
      @statut_demande = 5
    when 'AVFIECAIPRES'
      @pourcentage = 75
      @statut_demande = 6
    when 'IESV'
      @pourcentage = 100
      @statut_demande = 7
    when 'PENDING'
      immatriculation.update_attribute(:statut_demande, 8, :etat, 3)
      @pourcentage = 100
      @statut_demande = 8
    else
      #@immatriculation.update_attribute(:statut_demande, 9)
    end

    immatriculation.statut_demande = @statut_demande
    if @statut_demande >= 7
      immatriculation.etat = 3
    end
    immatriculation.save!

    if @statut_demande < 8
      ws_document_immatriculation
    else
      @pourcentage = 100
      @url = immatriculation.url
    end
  end
end