class Salarie::AllocationFamilialesController < Salarie::ApplicationController
  before_action :set_dossier_prestation
  before_action :set_allocation_familiale, except: [:index, :new, :create]

  def index
    @allocation_familiales = @dossier_prestation.allocation_familiales
  end

  def show
    @document_allocation_familiale = DocumentAllocatFamiliale.new
  end

  def new
    @allocation_familiale = AllocationFamiliale.new
  end

  def edit; end

  def create
    @allocation_familiale = AllocationFamiliale.new(allocation_familiale_params)
    @allocation_familiale.dossier_prestation = @dossier_prestation
    @allocation_familiale.user = current_user
    @allocation_familiale.ajoute_par = current_user
    @allocation_familiale.etat = :creation

    if @allocation_familiale.save
      redirect_to [:salarie, @dossier_prestation, @allocation_familiale], notice: 'Allocation familiale was successfully created.'
    else
      render :new
    end
  end

  def update
    if @allocation_familiale.update(allocation_familiale_params)
      redirect_to [:salarie, @dossier_prestation, @allocation_familiale], notice: 'Allocation familiale was successfully updated.'
    else
      render :edit
    end
  end

  def destroy
    @allocation_familiale.destroy
    redirect_to salarie_dossier_prestation_allocation_familiales_path, notice: 'Allocation familiale was successfully destroyed.'
  end

  def valider_documents
    @allocation_familiale.document_valid!
    redirect_to [:salarie, @dossier_prestation, @allocation_familiale]
  end

  def create_document
    @document_allocat_familiale = DocumentAllocatFamiliale.new(document_allocat_familiale_params)
    @document_allocat_familiale.allocation_familiale = @allocation_familiale
    @document_allocat_familiale.date_depot = Date.today

    if @document_allocat_familiale.save
      @allocation_familiale.document_valid!(false)
      redirect_to [:salarie, @dossier_prestation, @allocation_familiale], notice: 'Le document est ajouté.'
    else
      flash[:error] = "Une erreur est survenue lors de l'ajout du document."
      render :show
    end
  end

  def soumettre
    if @allocation_familiale.update(soumission_allocation_familiale_params.merge(etat: :soumis, date_soumission: Date.today))
      redirect_to salarie_dossier_prestation_allocation_familiales_path(@dossier_prestation), notice: "La demande d'allocation est soumise."
    else
      render :soumission_form
    end
  end

  def soumission_form; end

  private

  def set_allocation_familiale
    @allocation_familiale = AllocationFamiliale.find(params[:id] || params[:allocation_familiale_id])
  end

  def allocation_familiale_params
    params.require(:allocation_familiale).permit( :enfant_id, :trimestre, :annee)
  end

  def set_dossier_prestation
    @dossier_prestation = current_user.dossier_prestations.find(params[:dossier_prestation_id])
  end

  def soumission_allocation_familiale_params
    params.require(:allocation_familiale).permit(:condition_1, :condition_2)
  end

  def document_allocat_familiale_params
    params.require(:document_allocat_familiale).permit( :type_document, :document, :commentaire)
  end

  def peut_etre_edite!
    unless @allocation_familiale.creation?
      flash[:error] = "Vous ne pouvez pas éditer un dossier déjà soumis"
      redirect_to [:salarie, @allocation_familiale]
    end
  end
end
