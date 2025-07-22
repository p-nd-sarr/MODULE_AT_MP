class Salarie::DossierPrestationsController < Salarie::ApplicationController
  before_action :set_dossier_prestation, except: [:index, :new, :create, :update_document, :recipisse_dossier, :historique_dossier]
  before_action :peut_etre_edite!, except: [:index, :new, :create, :show, :enregistrer, :update_document, :recipisse_dossier, :historique_dossier]
  before_action :can_add!, only: [:new, :create]

  def index
    @dossier_prestations = current_user.dossier_prestations
  end

  def show
    @document_dossier_prestations = DocumentDossierPrestation.new
  end

  def new
    @dossier_prestation = DossierPrestation.new
    @dossier_prestation.prenom = current_user.prenom
    @dossier_prestation.nom = current_user.nom
    @dossier_prestation.adresse_domicile = current_user.adresse
  end

  def edit; end

  def create
    @dossier_prestation = DossierPrestation.new(dossier_prestation_params)
    @dossier_prestation.user = current_user
    @dossier_prestation.num_affiliation = current_user.numero_salarie
    @dossier_prestation.etat = :creation
    @dossier_prestation.ajoute_par = current_user

    if @dossier_prestation.save
      redirect_to [:salarie, @dossier_prestation], notice: 'Le dossier est créé.'
    else
      render :new
    end
  end

  def update
    if @dossier_prestation.update(dossier_prestation_params.merge({etat_civil_demandeur_valid: false}))
      redirect_to [:salarie, @dossier_prestation], notice: 'Dossier prestation was successfully updated.'
    else
      render :edit
    end
  end

  def destroy
    @dossier_prestation.destroy
    redirect_to [:salarie, @dossier_prestation], notice: 'Dossier prestation was successfully destroyed.'
  end

  def valider_etat_civil_demandeur
    @dossier_prestation.etat_civil_demandeur_valid!
    redirect_to [:salarie, @dossier_prestation]
  end

  def valider_enfants
    @dossier_prestation.enfants_valide!
    redirect_to [:salarie, @dossier_prestation]
  end

  def valider_carriere
    @dossier_prestation.carriere_valid!
    redirect_to [:salarie, @dossier_prestation]
  end

  def valider_documents
    @dossier_prestation.document_valid!
    redirect_to [:salarie, @dossier_prestation]
  end

  def create_document
    @document_dossier_prestation = DocumentDossierPrestation.new(document_dossier_prestation_params)
    @document_dossier_prestation.dossier_prestation = @dossier_prestation
    @document_dossier_prestation.date_depot = Date.today

    if @document_dossier_prestation.save
      @dossier_prestation.document_valid!(false)
      redirect_to [:salarie, @dossier_prestation], notice: 'Le document est ajouté.'
    else
      flash[:error] = "Une erreur est survenue lors de l'ajout du document."
      redirect_to [:salarie, @dossier_prestation]
    end
  end


  def update_document
    @document_dossier_prestation = DocumentDossierPrestation.find(params[:document_dossier_prestation_id])

    @document_dossier_prestation.update(document_dossier_prestation_params)
    redirect_to [:salarie, @document_dossier_prestation.dossier_prestation ], notice: 'Le document à été modifié avec succès'
  end

  def update_document_form
    @document_dossier_prestation = DocumentDossierPrestation.find(params[:document_dossier_prestation_id])
  end

  def destroy_document
    @document_dossier_prestation = DocumentDossierPrestation.find(params[:document_dossier_prestation_id])
    @document_dossier_prestation.destroy
    redirect_to [:salarie, @dossier_prestation], notice: 'Le document à été suprimé avec succès.'
  end


  def recipisse_dossier
    @dossier_prestation = DossierPrestation.find(params[:id] || params[:dossier_prestation_id])

    respond_to do |format|
      format.html
      format.pdf do
        render pdf: "Récépissé du dissier prestation  No. #{@dossier_prestation.id}",
               page_size: 'A4',
               template: "salarie/dossier_prestations/recipisse_dossier.html.erb",
               layout: "pdf.html",
               orientation: "Landscape",
               lowquality: true,
               zoom: 1,
               pi: 75
      end
    end
  end



  def historique_dossier
    @dossier_prestations = DossierPrestation.find(params[:dossier_prestation_id])

    render template: "/salarie/dossier_prestations/historique_dossier"
  end





  def soumettre
    if @dossier_prestation.update(soumission_dossier_prestation_params.merge(etat: :soumis, date_soumission: Date.today))
      redirect_to [:salarie, @dossier_prestation], notice: 'Le dossier de prestation est soumis !'
    else
      render :soumission_form
    end
  end

  def soumission_form; end

  private

  def set_dossier_prestation
    @dossier_prestation = current_user.dossier_prestations.find(params[:id] || params[:dossier_prestation_id])
  end

  def dossier_prestation_params
    params.require(:dossier_prestation).permit(:sexe_salarie, :num_affiliation, :prenom, :nom, :date_naissance,
                                               :lieu_naissance, :adresse_domicile, :etat, :date_soumission,
                                               :date_validation, :num_dossier, :conjoint_id)
  end

  def soumission_dossier_prestation_params
    params.require(:dossier_prestation).permit(:condition_1, :condition_2, :condition_3)
  end

  def document_dossier_prestation_params
    params.require(:document_dossier_prestation).permit( :type_document, :volet, :document, :commentaire)
  end

  def peut_etre_edite!
    unless @dossier_prestation.creation?
      flash[:error] = "Vous ne pouvez pas éditer un dossier déjà soumis"
      redirect_to [:salarie, @dossier_prestation]
    end
  end

  def can_add!
    unless current_user.can_add_dossier_prestation?
      flash[:error] = "Vous ne pouvez pas ajouter un nouveau dossier de prestation. Il y'a déjà un en cours"
      redirect_to salarie_dossier_prestations_path
    end
  end
end
