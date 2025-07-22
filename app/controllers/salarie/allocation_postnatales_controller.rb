class Salarie::AllocationPostnatalesController < Salarie::ApplicationController
  before_action :set_dossier_prestation
  before_action :set_allocation_postnatale, except: [:index, :new, :create]

  def index
    @allocation_postnatales = @dossier_prestation.allocation_postnatales
  end

  def show
    #show
  end

  def new
    @allocation_postnatale = AllocationPostnatale.new
    @enfant = @dossier_prestation.enfants.valide.find(params[:enfant_id])
  end

  def edit
    @enfant = @allocation_postnatale.enfant
  end

  def create
    @allocation_postnatale = AllocationPostnatale.new(allocation_postnatale_params)
    @allocation_postnatale.dossier_prestation = @dossier_prestation
    @allocation_postnatale.user = current_user
    @allocation_postnatale.ajoute_par = current_user
    @allocation_postnatale.etat = :creation

    if @allocation_postnatale.save
      redirect_to [:salarie, @dossier_prestation, @allocation_postnatale], notice: 'Allocation postnatale was successfully created.'
    else
      render :new
    end
  end

  def update
    if @allocation_postnatale.update(allocation_postnatale_params)
      redirect_to [:salarie, @dossier_prestation, @allocation_postnatale], notice: 'Allocation postnatale was successfully updated.'
    else
      render :edit
    end
  end

  def destroy
    @allocation_postnatale.destroy
    redirect_to salarie_dossier_prestation_allocation_postnatales_path(@dossier_prestation), notice: 'Allocation postnatale was successfully destroyed.'
  end

  def soumettre
    if @allocation_postnatale.update(soumission_allocation_postnatale_params.merge(etat: :soumis, date_soumission: Date.today))
      redirect_to salarie_dossier_prestation_allocation_postnatales_path(@dossier_prestation), notice: "La demande d'allocation est soumise."
    else
      render :soumission_form
    end
  end

  def soumission_form; end

  private

  def set_allocation_postnatale
    @allocation_postnatale = AllocationPostnatale.find(params[:id] || params[:allocation_postnatale_id])
  end

  def allocation_postnatale_params
    params.require(:allocation_postnatale).permit(:date_accouchement, :volet, :commentaire, :document, :enfant_id)
  end

  def set_dossier_prestation
    @dossier_prestation = current_user.dossier_prestations.find(params[:dossier_prestation_id])
  end

  def soumission_allocation_postnatale_params
    params.require(:allocation_postnatale).permit(:condition_1, :condition_2, :condition_3)
  end
end
