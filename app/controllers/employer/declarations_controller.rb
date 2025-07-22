class Employer::DeclarationsController < Employer::ApplicationController
  before_action :peut_acceder!

  def index
    @declarations = Declaration.soumis
    @historique_css_declarations = []

    @employeur = Psrm::Employeur.find_by(ancien_num_ipres: current_user.num_ipres)

    @historique_ipres_declarations = MissingDeclaration.where(numero_ipres: current_user.num_ipres)

  end

  def new
    @declaration = current_user.declarations.creation.where(periode: (DateTime.now.beginning_of_month..DateTime.now.end_of_month)).first

    @immatriculation = current_user.immatriculation

    @taux_at = 0
    @taux_at = @immatriculation.taux_at unless @immatriculation.taux_at.nil?


    @effectifs = current_user.salarie_immatriculations.actif.page(params[:page]).per(15)

    if @declaration.nil?
      @declaration = Declaration.new
      @declaration.user = current_user
      @declaration.statut = :creation
      @declaration.effectif = current_user.salarie_immatriculations.actif.size
      @declaration.periode = DateTime.now
      if @declaration.periode.day <= 25
        @declaration.periode = @declaration.periode - 1.month
      end
      calculer_montant()
      @declaration.save!
    end

    @active_mouvement = 'active'

    calcul_pourcentage()
  end

  def create
    #@declaration = Declaration.new(declaration_params)

    @declaration.mouvement_effectif_valide = true

    if @declaration.save
      # create declaration
      create_fusion_declaration

      redirect_to 'employer/declarations/new', notice: 'La déclaration est créée.'
    else
      flash[:error] = @declaration.errors.full_messages
      render :new
    end
  end

  def lignes_declaration;
  end

  def show
    @declaration = Psrm::EnteteDeclaration.where(ID_DECLARATION: params[:id]).first

    @ligne_declarations = Psrm::DeclarationLigne.where(ID_DECLARATION: @declaration.ID_DECLARATION)
  end

  def valider_mouvement
    @declaration = Declaration.find(params[:declaration_id])

    @declaration.mouvement_effectif_valide!
    redirect_to '/employer/declarations/new', notice: 'Le mouvement effectif validé.'
  end

  def valider_synthese
    @declaration = Declaration.find(params[:declaration_id])

    @declaration.synthese_valide!
    redirect_to '/employer/declarations/new', notice: 'La synthèse est validée.'
  end

  def valider_recapitulatif
    @declaration = Declaration.find(params[:declaration_id])

    @declaration.recap_salarie_valide!
    redirect_to '/employer/declarations/new', notice: 'Le mouvement effectif validé.'
  end

  def soumettre_declaration
    @declaration = Declaration.find(params[:declaration_id])

    ws_create_declaration(@declaration)

    redirect_to '/employer/declarations/new', notice: 'La déclaration est soumise.'
  end

  def ligne_declarations
    @declaration = MissingDeclaration.find(params[:declaration_id])
    @ligne_declarations = @declaration.missing_ligne_declarations

    @employeur = Psrm::Employeur.find_by(ancien_num_ipres: current_user.num_ipres)

    if @declaration.regime == "1"
      @declaration_last = MissingDeclaration.where(numero_ipres: current_user.num_ipres).general.valide.last
    else
      @declaration_last = MissingDeclaration.where(numero_ipres: current_user.num_ipres).cadre.valide.last
    end

    code_regime = @declaration.regime == "1" ? "GENERAL" : "CADRE"
    regime = Admin::TypeRegime.find_by_code(code_regime)
    if @ligne_declarations.empty? and not @declaration_last.nil?
      @ligne_declarations = @declaration_last.missing_ligne_declarations
      @ligne_declarations.each do |ligne|
        ligne_declaration = ligne.dup
        ligne_declaration.missing_declaration = @declaration
        ligne_declaration.etat = :creation
        ligne_declaration.type_regime = regime
        ligne_declaration.date_entree = ligne.date_entree.change(:year => Date.parse("01/01/#{@declaration.exercice}").year)
        ligne_declaration.date_sortie = ligne.date_sortie.change(:year => Date.parse("01/01/#{@declaration.exercice}").year)

        ligne_declaration.save
      end
    end

    @ligne_declaration = MissingLigneDeclaration.new
    @ligne_declaration.type_regime = regime
    @ligne_declaration.missing_declaration = @declaration
  end

  def ajouter_ligne
  end

  def import

    declaration_id = MissingDeclaration.last
    puts declaration_id
    if params[:file].nil?
      redirect_to '/employer/declarations', notice: "Fichier introuvable"
    else
      MissingLigneDeclaration.my_import(params[:file], declaration_id)
      redirect_to '/employer/declarations', notice: "Fichier salaire importé avec succés"
    end

  end


  private

  def calcul_pourcentage
    @pourcentage = 0
    if @declaration.mouvement_effectif_valide?
      @pourcentage += 33
    end

    if @declaration.recap_salarie_valide?
      @pourcentage += 33
    end

    if @declaration.synthese_valide?
      @pourcentage += 34
    end
  end

  def calculer_montant
    @salaries = current_user.salarie_immatriculations.actif
    montant_pf = 0
    montant_rg = 0
    montant_rcc = 0
    montant_at = 0
    @declaration.cumul_at = 0
    @declaration.cumul_pf = 0
    @declaration.cumul_rg = 0
    @declaration.cumul_rcc = 0
    @salaries.each do |salarie|
      montant_pf = montant_pf + salarie.montant_pf
      montant_rg = montant_rg + salarie.montant_rg
      montant_rcc = montant_rcc + salarie.montant_rcc
      montant_at = montant_at + salarie.montant_at(@taux_at)

      @declaration.cumul_at = @declaration.cumul_at + [63_000, salarie.salaire_contractuel].min
      @declaration.cumul_pf = @declaration.cumul_pf + [63_000, salarie.salaire_contractuel].min
      @declaration.cumul_rg = @declaration.cumul_rg + [360_000, salarie.salaire_contractuel].min

      if salarie.est_cadre?
        @declaration.cumul_rcc = @declaration.cumul_rcc + [1_080_000, salarie.salaire_contractuel].min
      end

      @declaration.cumul_salaire = @declaration.cumul_salaire + salarie.salaire_contractuel
    end

    @declaration.montant_at = montant_at
    @declaration.montant_pf = montant_pf
    @declaration.montant_rg = montant_rg
    @declaration.montant_rcc = montant_rcc

    @declaration.montant_total = (montant_at + montant_pf + montant_rg + montant_rcc).round
  end

  def create_fusion_declaration
    new_declaration = Psrm::EnteteDeclaration.new

    new_declaration.EFFECTIF = @declaration.effectif
    new_declaration.MONTANT_PF = @declaration.montant_pf
    new_declaration.MONTANT_AT = @declaration.montant_at
    new_declaration.MONTANT_DNT = @declaration.montant_total

    new_declaration.save!
  end

  def declaration_params
    params.require(:declaration).permit(:effectif, :montant_total, :montant_pf, :montant_at, :montant_rg, :montant_rcc)
  end

  def peut_acceder!
    @employeur = Psrm::Employeur.find_by(ancien_num_ipres: current_user.num_ipres)
    if @employeur.nil?
      @immatriculation = current_user.immatriculation
      if @immatriculation.nil? or @immatriculation.statut_demande != nil
        flash[:info] = "Immatriculation pas encore valide. Veillez faire la demande!"
        render '/employer/immatriculations/index'
      end
    end

  end

  def ws_create_declaration(declaration)
    require 'savon'

    namespaces = {
        "xmlns:dns" => "http://oracle.com/DNS_INBOUND_SERVICE.xsd",
    }

    logger.info "-----> call operations WS"
    # create a client for the service
    client = Savon.client(wsdl: "#{WS_IMM_BASE_PATH}/ouaf/XAIApp/xaiserver/DNS_INBOUND_SERVICE?wsdl",
                          #client = Savon.client(wsdl: 'http://192.168.125.23:6500/ouaf/XAIApp/xaiserver/DNS_INBOUND_SERVICE?wsdl',
                          basic_auth: WS_IMM_AUTH,
                          :raise_errors => true, # false if you don't want to see exceptions
                          pretty_print_xml: true,
                          logger: Rails.logger,
                          log_level: :debug,
                          log: true,
                          namespace_identifier: :dns,
                          element_form_default: :qualified,
                          env_namespace: :soapenv,
                          namespaces: namespaces,
                          convert_request_keys_to: :none)

    response = nil
    puts "----> operation : #{client.operations}"
    immatriculation = current_user.immatriculation
    informationEmployeur = {typeIdentifiant: 'SCI', idIdentifiant: immatriculation.ninea, raisonSociale: immatriculation.raison_sociale, adresse: immatriculation.adresse, typeDeclaration: 'MENSUEL',
                            dateDebutCotisation: @declaration.periode.at_beginning_of_month, dateFinCotisation: @declaration.periode.at_end_of_month}

    synthese = {totalNouvSalaries: 0, totalSalaries: @declaration.effectif, cumulTotSalAssIpresRg: @declaration.cumul_rg.round(-1), cumulTotSalAssIpresRcc: @declaration.cumul_rcc.round(-1),
                cumulTotSalAssCssPf: @declaration.cumul_pf.round(-1), cumulTotSalAssCssAtmp: @declaration.cumul_at.round(-1), totalSalVerses: @declaration.cumul_salaire.round(-1), mntCotPfCalcParEmployeur: @declaration.montant_pf.round(-1),
                mntCotAtMpCalcParEmployeur: @declaration.montant_at.round(-1), mntCotRgCalcParEmployeur: @declaration.montant_rg.round(-1), mntCotRccCalcParEmployeur: @declaration.montant_rcc.round(-1)}

    informationSalariesList = get_salaries_to_json()

    begin
      response = client.call(:dns_inbound_service) do
        message(input: {
            informationEmployeur: informationEmployeur,
            synthese: synthese,
            informationSalariesList: informationSalariesList
        })
      end
    rescue Savon::Error => error
      print "------->"
      printf error.to_s
    rescue Savon::Error => soap_fault
      print "=======>   "
      print "Error: #{soap_fault}\n"
    rescue Net::ReadTimeout => error
      printf error.to_s
    end

    if !response.nil? and response.success?
      @message_code = response.to_hash[:dns_inbound_service][:output][:process_flow_id]
      @message_content = response.to_hash[:dns_inbound_service][:output][:form_id]
      declaration.soumettre_demande!
    end
  end

  def get_salaries_to_json
    salaries = SalarieImmatriculation.where(user_id: current_user.id).actif
    immatriculation = current_user.immatriculation

    salaries_json = []
    salaries.each do |salarie|
      salarie_json = {numeroAssureSocial: '', nom: salarie.nom, prenomEmploye: salarie.prenom,
                      dateNaissance: salarie.date_naissance, typePieceIdentite: salarie.type_piece.upcase,
                      numeroPieceIdentite: salarie.nin, typeContrat: salarie.nin_cedeao,
                      dateEntree: salarie.date_debut_contrat, dateEffetRegimeCadre1: salarie.date_debut_contrat, totSalAssCssPf1: salarie.tot_sal_ass_css_pf1, totSalAssCssAtmp1: salarie.tot_sal_ass_css_atmp1,
                      totSalAssIpresRg1: salarie.tot_sal_ass_ipres_rg1, totSalAssIpresRcc1: salarie.tot_sal_ass_ipres_rcc1, salaireBrut1: salarie.salaire_contractuel.round(-1), nombreJours1: '24', nombreHeures1: '184',
                      tempsTravail1: 'TPS_PLEIN', trancheTravail1: '08h-17h', regimeGeneral1: true, regimCompCadre1: salarie.est_cadre
      }
      salaries_json << salarie_json
    end

    salaries_json
  end
end
