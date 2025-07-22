class Salarie::LiquidationRetraitesController < Salarie::ApplicationController
  before_action :set_demande_liquidation, except: [:index, :new, :create]
  before_action :peut_etre_edite!, except: [:index, :new, :create, :show, :show_facture]
  before_action :can_add!, only: [:new, :create]

  def index
    @demande_liquidations = current_user.liquidation_retraites
  end

  def show
    @document_demande_liquidation = DocumentLiquidationRetraite.new
  end

  def new
    @demande_liquidation = LiquidationRetraite.new
    @demande_liquidation.prenom = current_user.prenom
    @demande_liquidation.nom = current_user.nom
  end

  def edit; end

  def create
    @demande_liquidation = LiquidationRetraite.new(demande_liquidation_params)
    @demande_liquidation.user = current_user
    @demande_liquidation.ajoute_par = current_user
    @demande_liquidation.etat = :creation

    if @demande_liquidation.save
      redirect_to [:salarie, @demande_liquidation], notice: 'La demande de liquidation est créée.'
    else
      render :new
    end
  end

  def update
    if @demande_liquidation.update(demande_liquidation_params)
      @demande_liquidation.etat_civil_demandeur_valide!(false)
      redirect_to [:salarie, @demande_liquidation], notice: 'La demande de liquidation est bien mise à jour.'
    else
      render :edit
    end
  end

  def destroy
    @demande_liquidation.destroy
    redirect_to salarie_liquidation_retraites_path, notice: 'La demande de liquidation est supprimée.'
  end

  def valider_etat_civil_demandeur
    @demande_liquidation.etat_civil_demandeur_valide!
    redirect_to [:salarie, @demande_liquidation]
  end

  def valider_epouses
    @demande_liquidation.epouses_valide!
    redirect_to [:salarie, @demande_liquidation]
  end

  def valider_enfants
    @demande_liquidation.enfants_valide!
    redirect_to [:salarie, @demande_liquidation]
  end

  def valider_carriere
    @demande_liquidation.carriere_valide!
    redirect_to [:salarie, @demande_liquidation]
  end

  def valider_documents
    unless @demande_liquidation.documents_valide!
      flash[:error] = "Veuillez déposer tous les documents requis avant la validation"
    end
    redirect_to [:salarie, @demande_liquidation]
  end

  def destroy_document
    @document_demande_liquidation = DocumentLiquidationRetraite.find(params[:document_liquidation_retraites_id])
    @document_demande_liquidation.destroy
    redirect_to [:salarie, @demande_liquidation], notice: 'Le document a été supprimé avec succès'
  end


  def create_document
    @document_demande_liquidation = DocumentLiquidationRetraite.new(document_demande_liquidation_params)
    @document_demande_liquidation.liquidation_retraite = @demande_liquidation

    if @document_demande_liquidation.save
      @demande_liquidation.documents_valide!(false)
      redirect_to [:salarie, @demande_liquidation], notice: 'Le document est ajouté.'
    else
      flash[:error] = "Une erreur est survenue lors de l'ajout du document."
      render :show
    end
  end

  def show_facture
    @demande_liquidation = LiquidationRetraite.find(params[:id] || params[:liquidation_retraite_id])

    respond_to do |format|
      format.html
      format.pdf do
        render pdf: "Récépissé demande de liquidation No. #{@demande_liquidation.id}",
               page_size: 'A4',
               template: "admin/liquidation_retraites/show_facture.html.erb",
               layout: "pdf.html",
               orientation: "Landscape",
               lowquality: true,
               zoom: 1,
               pi: 75
      end
    end
  end

  def soumission_form; end

  def soumettre
    @demande_liquidation.etat = :soumis
    @demande_liquidation.date_soumission = DateTime.now
    if @demande_liquidation.save!
      redirect_to [:salarie, @demande_liquidation], notice: 'La demande de liquidation est soumise.'
    else
      redirect_to [:salarie, @demande_liquidation]
    end
  end

  private

  def set_demande_liquidation
    @demande_liquidation = current_user.liquidation_retraites.find(params[:id] || params[:liquidation_retraite_id])
  end

  def demande_liquidation_params
    params.require(:liquidation_retraite).permit(:type_retraite, :prenom, :nom, :date_naissance, :lieu_naissance,
                                                 :adresse_reception_allocation, :adresse_domicile, :mode_paiement,
                                                 :compte_bancaire_nom_banque, :compte_bancaire_code_banque,
                                                 :compte_bancaire_code_guichet, :compte_bancaire_numero_compte, :etat,
                                                 :date_cessation_activite, :documents_deposes)
  end

  def soumission_demande_liquidation_params
    params.require(:liquidation_retraite).permit(:condition_1, :condition_2, :condition_3)
  end

  def document_demande_liquidation_params
    params.require(:document_liquidation_retraite).permit(:type_document, :document, :commentaire)
  end

  def peut_etre_edite!
    unless @demande_liquidation.creation?
      flash[:error] = "Vous ne pouvez pas éditer une demande déjà soumise"
      redirect_to [:salarie, @demande_liquidation]
    end
  end

  def can_add!
    unless current_user.can_add_liquidation_retraite?
      flash[:error] = "Vous ne pouvez pas ajouter une nouvelle demande de liquidation retraite. Il y'a déjà une ou des demandes en cours"
      redirect_to salarie_liquidation_retraites_path
    end
  end
end
