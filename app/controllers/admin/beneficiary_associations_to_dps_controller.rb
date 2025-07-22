class Admin::BeneficiaryAssociationsToDpsController < ApplicationController

  before_action :set_beneficiary_association, except: [:create]

  def create
    @beneficiary_association = BeneficiaryAssociationsToDp.new(beneficiary_associations_params)
    puts 'dosierkvhk', params
    if @beneficiary_association.save
      redirect_to [:admin, @beneficiary_association.dossier_prestation], notice: 'Association ajoutée avec succès.'
    else
      error_message = @beneficiary_association.errors.full_messages
      flash[:error] = "Une erreur est survenue lors de la création", error_message
      redirect_to admin_dossier_prestation_path(@beneficiary_association.dossier_prestation_id)
    end
  end

  def destroy
    @beneficiary_association.destroy
    respond_to do |format|
      format.html { redirect_to [:admin, @beneficiary_association.dossier_prestation], notice: 'Association supprimée avec succès.' }
      format.json { head :no_content }
    end
  end

  private

  def set_beneficiary_association
    @beneficiary_association = BeneficiaryAssociationsToDp.find(params[:id])
  end

  def beneficiary_associations_params
    params.require(:beneficiary_associations_to_dp).permit(:dossier_prestation_id, :conjoint_id, :enfant_id, :attributaire_tierce_id, :type_beneficiary)
  end
end
