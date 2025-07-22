class Employer::AttestationsController < Employer::ApplicationController
  before_action :peut_acceder!
  def index
    @ninea= current_user.ninea
    @nom= current_user.nom
    @immatriculation = current_user.immatriculation
    @attestation = Attestation.new

    #cm_get_attestation_regularite()
    #cm_get_attes()
    cm_get_status_demande_attestation(@immatriculation)

    @attestations = Attestation.all.page(params[:page]).per(10)

  end

  def new
    @attestation = Attestation.new
  end

  def show
    @attestation = Attestation.find(params[:id])
    #ws_get_facture(@facture)
  end

  def create
    @attestation = Attestation.new(attestation_params)
    @attestation.user = current_user
    @attestation.etat = :creation
    if @attestation.save
      redirect_to [:employer,'attestations'] , notice: "attestation créée avec succès."
    else
      puts @attestation.errors.full_messages
      flash[:error] = @attestation.errors.full_messages
      redirect_to [:employer,'attestations'] , notice: ""
    end

  end

  def peut_acceder!
    @immatriculation = current_user.immatriculation
    if @immatriculation == nil or @immatriculation.statut_demande != nil
      flash[:info] = "Immatriculation pas encore valide. Veillez faire la demande!"
      redirect_to [:employer, 'immatriculations']
    end
  end

  def ws_get_facture(facture)
    require 'savon'

    namespaces = {
        "xmlns:cmg" => "http://oracle.com/Cm_getDNsCer_XAI.xsd",
    }

    logger.info "-----> call operations WS list factures"
    # create a client for the service
    #client = Savon.client(wsdl: 'http://192.168.125.23:6500/ouaf/XAIApp/xaiserver/Cm_getDNsCer_XAI?wsdl',
    client = Savon.client(wsdl: '#{WS_IMM_BASE_PATH}/ouaf/XAIApp/xaiserver/CM-PAYDNSXAI?wsdl',
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

    puts "----> operation : #{client.operations}"
    begin

      response = client.call(:cm_get_d_ns_cer_xai) do
        message( input:{
            taxFormId: facture.reference_facture
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

      url = response.to_hash[:cm_get_d_ns_cer_xai][:output][:url]

      end

      puts "results : #{url}"

    facture.update_attribute(:url, url)

  end

  def cm_get_attestation_regularite()
    require 'savon'

    namespaces = {
        "xmlns:cmg" => "http://oracle.com/CM-PAYDNSXAI.xsd",
    }

    logger.info "-----> call operations WS list factureq"
    # create a client for the service
    client = Savon.client(wsdl: "#{WS_IMM_BASE_PATH}/ouaf/XAIApp/xaiserver/CmGetAttestationRegularite?wsdl",
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

    puts "----> operation : #{client.operations}"
    begin

      response = client.call(:cm_get_attestation_regularite) do
        message(
            input: {typeIdentifiant: '', numeroIdentifiant: ''}
        )

      end

    rescue Savon::Error => error
      printf error.to_s
    rescue Savon::Error => soap_fault
      print "Error: #{soap_fault}\n"
    rescue Net::ReadTimeout => error
      printf error.to_s
    end

    if !response.nil? and response.success?


    end

    end


  def cm_get_attes()
    require 'savon'

    namespaces = {
        "xmlns:cmg" => "http://oracle.com/CM-PAYDNSXAI.xsd",
    }

    logger.info "-----> call operations WS list factureq"
    # create a client for the service
    #client = Savon.client(wsdl: 'http://192.168.125.23:6500/ouaf/XAIApp/xaiserver/CM-PAYDNSXAI?wsdl',
    client = Savon.client(wsdl: "#{WS_IMM_BASE_PATH}/ouaf/XAIApp/xaiserver/CM_GEN_ATTESTATION?WSDL",
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

    puts "----> operation : #{client.operations}"
    begin

      response = client.call(:cm_gen_attestation) do
        message(
            input: {reportTemplate: '', reportKey: '', parameters:{name: '', value: ''}}
        )

      end

    rescue Savon::Error => error
      printf error.to_s
    rescue Savon::Error => soap_fault
      print "Error: #{soap_fault}\n"
    rescue Net::ReadTimeout => error
      printf error.to_s
    end

    if !response.nil? and response.success?

    end

  end

  def cm_get_status_demande_attestation(immatriculation)
    require 'savon'

    namespaces = {
        "xmlns:cmg" => "http://oracle.com/CM-PAYDNSXAI.xsd",
    }

    logger.info "-----> call operations WS list factureq"
    # create a client for the service
    #client = Savon.client(wsdl: 'http://192.168.125.23:6500/ouaf/XAIApp/xaiserver/CM-PAYDNSXAI?wsdl',
    client = Savon.client(wsdl: "#{WS_IMM_BASE_PATH}/ouaf/XAIApp/xaiserver/CM-GetStatusDemandeAttestation?WSDL",
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

    puts "----> operation : #{client.operations}"
    begin

      response = client.call(:cm_get_status_demande_attestation) do
        message(
            input: {idDossier:  immatriculation.process_flow_id}
        )

      end

    rescue Savon::Error => error
      printf error.to_s
    rescue Savon::Error => soap_fault
      print "Error: #{soap_fault}\n"
    rescue Net::ReadTimeout => error
      printf error.to_s
    end

    if !response.nil? and response.success?

    end

  end

  private
  def attestation_params
    params.require(:attestation).permit(:titre)
  end
end