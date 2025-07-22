class Salarie::DossierMaternitesController < Salarie::ApplicationController
  before_action :set_dossier_maternite, except: [:index, :new, :create, :update_document, :recipisse_dossier, :historique_dossier]
  before_action :peut_etre_edite!, except: [:index, :new, :create, :show, :update_document, :recipisse_dossier, :historique_dossier]
  before_action :can_add!, only: [:new, :create]

  # GET /dossier_maternites
  # GET /dossier_maternites.json
  def index
    @dossier_maternites = current_user.dossier_maternites
    #@dossier_maternites = DossierMaternite.all
  end

  # GET /dossier_maternites/1
  # GET /dossier_maternites/1.json
  def show
    @document_dossier_maternite = DocumentDossierMaternite.new
  end

  # GET /dossier_maternites/new
  def new
    @dossier_maternite = DossierMaternite.new
    @dossier_maternite.prenom = current_user.prenom
    @dossier_maternite.nom = current_user.nom
    @dossier_maternite.adresse_domicile = current_user.adresse
  end

  # GET /dossier_maternites/1/edit
  def edit
    #edit
  end

  # POST /dossier_maternites
  # POST /dossier_maternites.json
  def create
    @dossier_maternite = DossierMaternite.new(dossier_maternite_params)
    @dossier_maternite.user = current_user
    @dossier_maternite.num_affiliation = current_user.numero_salarie
    @dossier_maternite.etat = :creation
    @dossier_maternite.ajoute_par = current_user

    if @dossier_maternite.save
      redirect_to [:salarie, @dossier_maternite], notice: 'Le dossier est créé.'
    else
      render :new
    end
  end


  def update
    if @dossier_maternite.update(dossier_maternite_params.merge({etat_civil_demandeur_valid: false}))
      redirect_to [:salarie, @dossier_maternite], notice: 'Dossier maternite was successfully updated.'
    else
      render :edit
    end
  end

  def destroy
    @dossier_maternite.destroy
    redirect_to [:salarie, @dossier_maternite], notice: 'Dossier maternite was successfully destroyed.'
  end

  def valider_etat_civil_demandeur
    @dossier_maternite.etat_civil_demandeur_valid!
    redirect_to [:salarie, @dossier_maternite]
  end

  def valider_epouses
    @dossier_maternite.conjoint_valid!
    redirect_to [:salarie, @dossier_maternite]
  end

  def valider_enfants
    @dossier_maternite.enfants_valide!
    redirect_to [:salarie, @dossier_maternite]
  end

  def valider_carriere
    @dossier_maternite.carriere_valid!
    redirect_to [:salarie, @dossier_maternite]
  end

  def valider_documents
    @dossier_maternite.document_valid!
    redirect_to [:salarie, @dossier_maternite]
  end

  def create_document
    @document_dossier_maternite = DocumentDossierMaternite.new(document_dossier_maternite_params)
    @document_dossier_maternite.dossier_maternite = @dossier_maternite
    @document_dossier_maternite.date_depot = Date.today

    if @document_dossier_maternite.save
      @dossier_maternite.document_valid!(false)
      redirect_to [:salarie, @dossier_maternite], notice: 'Le document est ajouté.'
    else
      flash[:error] = "Une erreur est survenue lors de l'ajout du document."
      render :show
    end
  end

  def update_document
    @document_dossier_maternite = DocumentDossierMaternite.find(params[:document_dossier_maternite_id])
    @document_dossier_maternite.update(document_dossier_maternite_params)
    redirect_to [:salarie, @document_dossier_maternite.dossier_maternite ], notice: 'Le document à été modifié avec succès'
  end

  def update_document_form
    @document_dossier_maternite = DocumentDossierMaternite.find(params[:document_dossier_maternite_id])
  end

  def destroy_document
    @document_dossier_maternite = DocumentDossierMaternite.find(params[:document_dossier_maternite_id])
    @document_dossier_maternite.destroy
    redirect_to [:salarie, @dossier_maternite], notice: 'Le document à été suprimer avec succès.'
  end



  def recipisse_dossier
    @dossier_maternite = DossierMaternite.find(params[:id] || params[:dossier_maternite_id])

    respond_to do |format|
      format.html
      format.pdf do
        render pdf: "Récépissé du dossier de maternité No. #{@dossier_maternite.id}",
               page_size: 'A4',
               template: "salarie/dossier_maternites/recipisse_dossier.html.erb",
               layout: "pdf.html",
               orientation: "Landscape",
               lowquality: true,
               zoom: 1,
               pi: 75
      end
    end
  end


  def historique_dossier
    @dossier_maternite = DossierMaternite.find(params[:dossier_maternite_id])

    render template: "/salarie/dossier_maternites/historique_dossier"
  end




  def soumettre
    if @dossier_maternite.update(soumission_dossier_maternite_params.merge(etat: :soumis, date_soumission: Date.today))
      redirect_to [:salarie, @dossier_maternite], notice: 'Le dossier de maternite est soumis !'
    else
      render :soumission_form
    end
  end

  def soumission_form; end

  private
    # Use callbacks to share common setup or constraints between actions.
    def set_dossier_maternite
      @dossier_maternite = current_user.dossier_maternites.find(params[:id] || params[:dossier_maternite_id])
    end

    # Never trust parameters from the scary internet, only allow the white list through.
    def dossier_maternite_params
      params.require(:dossier_maternite).permit(:num_affiliation, :prenom, :nom, :date_naissance, :lieu_naissance,
                                                :adresse_domicile, :debut_grossesse)
    end

    def soumission_dossier_maternite_params
      params.require(:dossier_maternite).permit(:condition_1, :condition_2, :condition_3)
    end
  
    def document_dossier_maternite_params
      params.require(:document_dossier_maternite).permit( :type_document, :volet, :document, :commentaire)
    end
  
    def peut_etre_edite!
      unless @dossier_maternite.creation?
        flash[:error] = "Vous ne pouvez pas éditer un dossier déjà soumis"
        redirect_to [:salarie, @dossier_maternite]
      end
    end
  
    def can_add!
      unless current_user.can_add_dossier_maternite?
        flash[:error] = "Vous ne pouvez pas ajouter un nouveau dossier de conges maternite. Il y'a déjà un en cours"
        redirect_to salarie_dossier_maternites_path
      end
    end
end
