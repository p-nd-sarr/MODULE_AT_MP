class Employer::FacturesController < Employer::ApplicationController
  before_action :peut_acceder!

  def index
    immatriculation = current_user.num_immatriculation

    unless immatriculation.nil?
      ws_list_factures(immatriculation)
    end

    @factures_close = Facture.where("statut = 1").order("created_at DESC").page(params[:page]).per(10)

    @factures_open = Facture.where("statut = 0").order("created_at DESC").page(params[:page]).per(10)

  end

  def new
    @facture = Facture.new
  end

  def show
    @facture = Facture.find(params[:id])
    ws_get_facture(@facture)
  end

  def create

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

    # create a client for the service
    client = Savon.client(wsdl: "#{WS_IMM_BASE_PATH}/ouaf/XAIApp/xaiserver/CM-PAYDNSXAI?wsdl",
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

      response = client.call(:cm_get_d_ns_cer_xai) do
        message(input: {
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
      facture.update_attribute(:url, url)

    end

  end


  def ws_list_factures(immatriculation)
    require 'savon'

    namespaces = {
        "xmlns:cmg" => "http://oracle.com/CM-PAYDNSXAI.xsd",
    }

    # create a client for the service
    client = Savon.client(wsdl: "#{WS_IMM_BASE_PATH}/ouaf/XAIApp/xaiserver/CM-PAYDNSXAI?wsdl",
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

      response = client.call(:cm_paydnsxai) do
        message(
            acctId: immatriculation.employer_registration_form_id
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

      factures = response.to_hash[:cm_paydnsxai][:results]
      init_factures(factures)

    end

  end

  private

  def init_factures(factures)
    unless factures.nil?
      Facture.where(statut: 0).destroy_all
      factures.each do |f|
        facture = Facture.new
        facture.reference_facture = f[:numero_facture]
        facture.type_facture = f[:type_facture]
        facture.echeance = f[:date_echeance]
        facture.date_fin = f[:date_fin]
        facture.date_debut = f[:date_debut]
        facture.periode = f[:date_debut]
        facture.montant_principal = f[:montant_principal]
        facture.montant = f[:montant_total]
        facture.majorations = f[:majorations]
        facture.dette = f[:dette]
        facture.montant_paye = f[:montant_paye]
        facture.penalite = f[:penalite]
        facture.montant_verse = f[:montant_verse]
        facture.dette_input = f[:detteinput]
        facture.solde = f[:detteinput]
        facture.user = current_user
        facture.date_facture = f[:date_debut]

        facture.save!
      end
    end
  end

end