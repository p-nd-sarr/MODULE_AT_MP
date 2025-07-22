class Salarie::AllocationPrenatalesController < Salarie::ApplicationController
  before_action :set_dossier_prestation
  before_action :set_allocation_prenatale, except: [:index, :new, :create]
  before_action :can_soumettre, only: [:soumettre]

  def index
    @allocation_prenatales = @dossier_prestation.allocation_prenatales
  end

  def show
    #show
  end

  def new
    @allocation_prenatale = AllocationPrenatale.new
    @grossesse = @dossier_prestation.grossesses.find(params[:grossesse_id])
  end

  def edit
    @grossesse = @allocation_prenatale.grossesse
  end

  def create

    @allocation_prenatale = AllocationPrenatale.new(allocation_prenatale_params)
    @allocation_prenatale.dossier_prestation = @dossier_prestation
    @allocation_prenatale.user = current_user
    @allocation_prenatale.ajoute_par = current_user
    @allocation_prenatale.etat = :creation

    if @allocation_prenatale.save
      redirect_to [:salarie, @dossier_prestation, @allocation_prenatale], notice: 'Allocation prenatale was successfully created.'
    else
      render :new
    end
  end

  def update
    if @allocation_prenatale.update(allocation_prenatale_params)
      redirect_to [:salarie, @dossier_prestation, @allocation_prenatale], notice: 'Allocation prenatale was successfully updated.'
    else
      render :edit
    end
  end

  def destroy
    @allocation_prenatale.destroy
    redirect_to salarie_dossier_prestation_allocation_prenatales_path(@dossier_prestation), notice: 'Allocation prenatale was successfully destroyed.'
  end

  def soumettre
    if @allocation_prenatale.update(soumission_allocation_prenatale_params.merge(etat: :soumis, date_soumission: Date.today))
      redirect_to salarie_dossier_prestation_allocation_prenatales_path(@dossier_prestation), notice: "La demande d'allocation est soumise."
    else
      render :soumission_form
    end
  end

  def soumission_form; end

  private

  def can_soumettre
    if @allocation_prenatale.dossier_prestation.creation?
      flash[:error] = "Vous ne pouvez pas soumettre cette prestation. Le dossier n'est pas soumis."
      redirect_to salarie_dossier_prestation_allocation_prenatales_path
    end
  end

  def set_allocation_prenatale
    @allocation_prenatale = AllocationPrenatale.find(params[:id] || params[:allocation_prenatale_id])
  end

  def allocation_prenatale_params
    params.require(:allocation_prenatale).permit(:grossesse_id, :volet, :commentaire, :document)
  end

  def set_dossier_prestation
    @dossier_prestation = current_user.dossier_prestations.find(params[:dossier_prestation_id])
  end

  def soumission_allocation_prenatale_params
    params.require(:allocation_prenatale).permit(:condition_1, :condition_2, :condition_3)
  end
end
