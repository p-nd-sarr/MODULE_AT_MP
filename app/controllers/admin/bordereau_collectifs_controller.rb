class Admin::BordereauCollectifsController < ApplicationController

  before_action :set_bordereau, only: [:update]

  def update
    if @bordereau.update(bordereau_params)
      redirect_to admin_traitement_collectif_ouvrir_bordereau_path(@bordereau.psrm_employeur.fhnum, @bordereau.numero_bordereau), notice: 'Base reversion was successfully updated.'
    else
      flash[:error] = @bordereau.errors.full_messages
      redirect_to admin_traitement_collectif_ouvrir_bordereau_path(@bordereau.psrm_employeur.fhnum, @bordereau.numero_bordereau)
    end
  end

  def set_bordereau
    @bordereau = BordereauCollectif.find(params[:id])
  end

  def bordereau_params
    params.require(:bordereau_collectif).permit(:document, :date_document)
  end

end
