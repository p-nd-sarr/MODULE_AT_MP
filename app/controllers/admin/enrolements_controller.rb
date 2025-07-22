class Admin::EnrolementsController < ApplicationController
  def regularisations
    @regularisations = Enrolement::RegularisationPointage.all.includes(:traite_par).order('created_at DESC').page(params[:page]).per(50)
    total_traite = Enrolement::RegularisationPointageLigne.joins(:regularisation_pointage).where(enrolement_regularisation_pointages: { workflow_state: :comptabilise }).count
    @evolution_traitement = 100 * total_traite / 59_210
  end

  def show_regularisation
    @regularisation = Enrolement::RegularisationPointage.find(params[:regularisation_id])
    @total = @regularisation.lignes.count
    @total_supprime = @regularisation.lignes.where(supprime: true).count

    @q = @regularisation.lignes.ransack(params[:q])
    @lignes = @q.result.order('pres_nom, pres_prenom, id DESC').page(params[:page]).per(100)
  end

  def valider_regularisation
    @regularisation = Enrolement::RegularisationPointage.find(params[:regularisation_id])
    @regularisation.valider!(current_user)

    redirect_to regularisation_admin_enrolements_path(regularisation_id: @regularisation.id)
  end

  def rejeter_regularisation
    @regularisation = Enrolement::RegularisationPointage.find(params[:regularisation_id])
    @regularisation.rejeter!(current_user)

    redirect_to regularisation_admin_enrolements_path(regularisation_id: @regularisation.id)
  end

  def delete_regularisation_ligne
    @regularisation = Enrolement::RegularisationPointage.find(params[:regularisation_id])
    @ligne = @regularisation.lignes.find(params[:regularisation_ligne_id])
    @ligne.supprimer!(current_user)
    @total_supprime = @regularisation.lignes.where(supprime: true).count
    # redirect_to regularisation_admin_enrolements_path(regularisation_id: @regularisation.id)
  end

  def paiements_regularisation
    @regularisation = Enrolement::RegularisationPointage.find(params[:regularisation_id])
    # @montant_total = @regularisation.compta_transactions.sum(:montant)
    @q = @regularisation.ordre_paiements.ransack(params[:q])
    @nombre_dossiers = @q.result.count(:numero_allocataire)
    @ordre_paiements = @q.result.includes(:allocataire, :compta_transactions).order('numero desc')
    @ordre_paiements = @ordre_paiements.page(params[:page]).per(100)
  end
end
