class Admin::GrossessesController < Admin::ApplicationController
  before_action :set_dossier_prestation
  before_action :set_grossesse, except: [:index, :new, :create]

  def index
    @grossesses = @dossier_prestation.grossesses
  end

  def show
    #show
  end

  def interruption_form; end

  def new
    @grossesse = Grossesse.new
  end

  def edit

  end

  def create
    @grossesse = Grossesse.new(grossesse_params)
    @grossesse.dossier_prestation = @dossier_prestation

    if @grossesse.save
      redirect_to admin_dossier_prestation_allocation_prenatales_path(@dossier_prestation), notice: 'Grossesse was successfully created.'
    else
      render :new
    end
  end

  def update
    if @grossesse.update(grossesse_params_update)
      redirect_to admin_dossier_prestation_allocation_prenatales_path(@dossier_prestation), notice: 'Grossesse was successfully updated.'
    else
      flash[:error] = 'La date renseignée n’est pas valide.'
      render :'interruption_form'
    end
  end

  def destroy
    @grossesse.destroy
    redirect_to admin_dossier_prestation_allocation_prenatales_path(@dossier_prestation), notice: 'Grossesse was successfully destroyed.'
  end

  private

  def set_grossesse
    @grossesse = Grossesse.find(params[:id] || params[:grossesse_id])
  end

  def grossesse_params
    params.require(:grossesse).permit(:date_grossesse, :etat)
  end

  def grossesse_params_update
    params.require(:grossesse).permit(:etat, :date_interruption, :date_grossesse)
  end

  def set_dossier_prestation
    @dossier_prestation = DossierPrestation.find(params[:dossier_prestation_id])
  end
end
