class Admin::HomeController < Admin::ApplicationController
  before_action :only_admin!, only: [:viderrrrrrr]

  def index
    @total_demande = LiquidationRetraite.count + ArretTravail.count + DossierPrestation.count + DossierMaternite.count + MaladieProfessionnelle.count + PrestationExterieure.count
  end

  def viderrrrrrr
    if Rails.env == 'production'
      render plain: 'Hey ... vous êtes en prod !!! Yangui prod dé ...'
    else

      y = params[:y].to_i
      m = params[:m].to_i
      d = params[:d].to_i

      if Date.new(y, m, d) == Date.today
        WorkflowHistory.destroy_all

        AllocationFamiliale.destroy_all
        AllocationPostnatale.destroy_all
        AllocationPrenatale.destroy_all
        Grossesse.destroy_all
        MaintienPrestation.destroy_all
        DossierPrestation.destroy_all
        IndemniteCongesMaternite.destroy_all
        DossierMaternite.destroy_all
        LiquidationRetraite.destroy_all

        AtIncapacite.destroy_all
        AtDecompte.destroy_all
        AtLesion.destroy_all
        AtAvi.destroy_all
        AtFraisEngage.destroy_all
        AtEvent.destroy_all
        AtCodePrimeSalaire.destroy_all
        AtConsolidation.destroy_all
        AtDossierReversionRente.destroy_all
        AtBaseReversionRente.destroy_all

        MpDocument.destroy_all
        MaladieProfessionnelle.destroy_all

        AtSalaire.destroy_all
        ArretTravail.destroy_all
        BaseReversion.destroy_all
        ReversionVeuve.destroy_all
        DossierReversionSalary.destroy_all
        BaseReversionSalary.destroy_all
        Historique.destroy_all
        Enfant.destroy_all
        Salarie.destroy_all
        Conjoint.destroy_all
        IndemnitesPrestationExterieure.destroy_all
        CafEnfant.destroy_all
        CafConjoint.destroy_all
        PrestationExterieure.destroy_all
        AscendantsSalarie.destroy_all
        ComptaTransaction.destroy_all
        OrdrePaiement.destroy_all
        PaiementAllocataire.where.not(echeance_paiement: nil).destroy_all
        EcheancePaiement.destroy_all
        Allocataire.where(est_repris: false).destroy_all
        Carriere.destroy_all

        Salarie.destroy_all

        render plain: "Done"
      else
        render plain: "Date invalide"
      end
    end
  end
end
