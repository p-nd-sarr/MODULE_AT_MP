class Admin::AllocatairePfController < Admin::ApplicationController
  before_action :set_dossier_prestation_f, only: [:show, :create_maintien_prestations, :maintien_prestations]


  def index
    @numero_affiliations = AllocatairePf.distinct.pluck(:numero_allocataire)
    @allocataire_pfs = Array.new
    @numero_affiliations.each { |i|
      @allocataire_pfs << AllocatairePf.find_by(numero_allocataire: i)
    }
  end


  ######--------------------params create alocataire---------------------
  def allocatairepf_params
    params.require(:allocataire_pf).permit(:prenom, :nom, :numero_allocataire, :date_naissance, :lieu_naissance,
                                        :sexe, :regime_matrimoniale, :nombre_conjoint, :nombre_enfants, :nationalite_id,
                                        :type_national, :adresse, :numero_employeur, :adresse_employeur, :mode_paiement,
                                        :telephone)
  end

  private def maintien_prestations_params
    params.require(:maintien_prestation).permit(:document_justificatif, :type_maintien, :commentaire)
  end

  private def set_dossier_prestation_f
    @dossier_prestation_allocataire = DossierPrestation.where(num_affiliation: params[:id] || params[:allocataire_pf_id])

    if @dossier_prestation_allocataire.length == 0
      @dossier_prestation_allocataire = nil
      return
    end

    if @dossier_prestation_allocataire.first.participant.homme?
      @dossier_prestation_f = DossierPrestation.all.where(num_affiliation: params[:id] || params[:allocataire_pf_id]).where(conjoint_id: nil).first
    else
      @dossier_prestation_f = @dossier_prestation_allocataire.first
    end
  end

  def new
    @allocataire_pf = AllocatairePf.new
  end

  def create
    @allocataire_pf = AllocatairePf.new(allocatairepf_params)
    if @allocataire_pf.save
      @item = AllocatairePf.last
      redirect_to admin_allocataire_pf_path(@item.numero_allocataire), notice: "L'allocataire' est créé."
    else
      render :new
    end
  end

  def show
    @dossier_prestation_allocataire = DossierPrestation.all.where(num_affiliation: params[:id])
    @allocataire_pf = AllocatairePf.find_by(numero_allocataire: params[:id])
    @dossier_prestation = DossierPrestation.find_by(num_affiliation: params[:id])
    @allocation_postnatales = AllocationPostnatale.find_by_sql(["select ap.volet, ap.etat, ap.created_at, ap.date_liquidation, ap.montant_paiement, ap.date_validation, ap.date_paiement, ap.date_soumission, ap.enfant_id
		                          from allocation_postnatales ap, allocataire_pfs ap2 ,dossier_prestations dp
		                          where ap.dossier_prestation_id  = dp.id and ap2.numero_allocataire = dp.num_affiliation and ap2.numero_allocataire = ?", params[:id] ])
    @allocation_prenatales = AllocationPrenatale.find_by_sql(["select ap.volet, ap.etat, ap.created_at, ap.date_liquidation, ap.montant_paiement, ap.date_validation, ap.date_paiement, ap.date_soumission
		                          from allocation_prenatales ap, allocataire_pfs ap2 ,dossier_prestations dp
		                          where ap.dossier_prestation_id  = dp.id and ap2.numero_allocataire = dp.num_affiliation and ap2.numero_allocataire = ?", params[:id] ])
    @conjoints = Conjoint.all.where(numero_affiliation: params[:id])
    @enfants = Enfant.all.where(numero_affiliation: params[:id])
    @paiements = PaiementAllocataire.where(numero_allocataire: params[:id]).order("created_at DESC").page(params[:page]).per(10)
  end

  def allocation_per_salarie
    @allocation_familiales = AllocationFamiliale.joins(:dossier_prestation).where(dossier_prestations: {num_affiliation: params[:allocataire_pf_id]})
  end

  def maintien_prestations
    @maintien_prestation = MaintienPrestation.new
    @maintien_prestation_last = MaintienPrestation.where(dossier_prestations_id: @dossier_prestation_f.id).last
  end

  def create_maintien_prestations
    date_demande = Date.today
    @maintien_prestation = MaintienPrestation.new(maintien_prestations_params)
    @maintien_prestation.type_maintien = MaintienPrestation.type_maintiens[:chomage]
    @maintien_prestation.dossier_prestation = @dossier_prestation_f
    @maintien_prestation.date_demande_maintien = date_demande
    @maintien_prestation.date_arret_maintien = @dossier_prestation_f.get_date_arret_maintien(@maintien_prestation)
    @maintien_prestation.assign_params_from_controller(current_user)
    @maintien_prestation.save

    if @dossier_prestation_f.valide?
      @dossier_prestation_f.est_suspendu!
      @dossier_prestation_f.suspandu_par = current_user
      @dossier_prestation_f.date_suspension = Date.today
      @dossier_prestation_f.save
    end
    redirect_to admin_allocataire_pf_maintien_prestations_path(@dossier_prestation_f.num_affiliation), notice: 'La demande de maintien a été enregistrée avec succès'

  end

end
