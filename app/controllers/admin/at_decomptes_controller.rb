class Admin::AtDecomptesController < Admin::ApplicationController
  before_action :set_at_decompte, except: [:new, :create, :index]
  before_action :set_arret_travail, only: [:destroy, :update, :edit, :show_recu, :rejeter, :show, :convoquer, :valider_comptable]

  def index
    @at_decomptes = AtDecompte.all
  end

  def new
    @at_decompte = AtDecompte.new
  end

  def show
    #show
  end

  def edit
  end

  def create
    @at_decompte = AtDecompte.new(at_decompte_params)
    @at_decompte.arret_travail = @arret_travail
    @at_decompte.etat = :creation
    if @at_decompte.save
      redirect_to [:admin, @at_decompte, @at_decompte], notice: 'Arret a été ajouté avec succés.'
    else
      render :new
    end
  end

  def update
    @arret_travail = ArretTravail.find(@at_decompte.arret_travail_id)
    if @at_decompte.update(at_decompte_params)
      puts "PARAM", at_decompte_params
      redirect_to [:admin, @arret_travail, @at_decompte], notice: 'Arret a été bien mis à jour.'
    else
      render :edit
    end
  end

  def liquider
    @arret_travail = @at_decompte.arret_travail
    @at_decompte.date_liquidation = DateTime.now.to_date.strftime("%d/%m/%Y").to_s
    @at_decompte.liquider!(current_user)
    @at_decompte.liquide_par = current_user
    if @at_decompte.save
      redirect_to [:admin, @arret_travail, @at_decompte], notice: 'Arret a été liquidé avec succés.'
    end
  end

  def valider
    @arret_travail = @at_decompte.arret_travail
    @at_decompte.date_validation = DateTime.now.to_date.strftime("%d/%m/%Y").to_s
    @at_decompte.etat = :valide
    @at_decompte.validation_par = current_user
    if @at_decompte.save
      redirect_to [:admin, @arret_travail, @at_decompte], notice: 'Arret a été validé avec succés.'
    end
  end

  def activer
    @arret_travail = @at_decompte.arret_travail
    @at_decompte.date_activation = DateTime.now.to_date.strftime("%d/%m/%Y").to_s
    if @at_decompte.solicite_medecin?
      @at_decompte.etat = :soumission_medecin
    else
      @at_decompte.etat = :creation
    end
    @at_decompte.active_par = current_user
    if @at_decompte.save
      redirect_to [:admin, @arret_travail, @at_decompte], notice: 'Arret a été activé avec succés.'
    end
  end

  def valider_medecin
    @arret_travail = @at_decompte.arret_travail
    @at_decompte.date_validation_medecin = DateTime.now.to_date.strftime("%d/%m/%Y").to_s
    @at_decompte.etat = :validation_medecin
    @at_decompte.validation_medecin_conseil_par = current_user
    if @at_decompte.save
      redirect_to [:admin, @arret_travail, @at_decompte], notice: 'Arret a été validé par le medecin conseil.'
    end
  end

  def valider_comptable
    ValiderPaiementAtDecompteJob.perform_now(@at_decompte, current_user)
    redirect_to [:admin, @arret_travail, @at_decompte], notice: 'Arret a été validé par le comptable.'
  end

  def annuler_liquidation
    @arret_travail = @at_decompte.arret_travail
    if @at_decompte.solicite_medecin?
      @at_decompte.etat = :soumission_medecin
    else
      @at_decompte.etat = :creation
    end
    @at_decompte.date_liquidation = nil
    @at_decompte.liquide_par = nil
    if @at_decompte.save
      redirect_to [:admin, @arret_travail, @at_decompte], notice: 'La liquidation a été annulée avec succés!!!.'
    end

  end

  # DELETE /admin/at_frais_engage/1
  # DELETE /admin/at_frais_engage/1.json
  def destroy
    @at_decompte.destroy
    respond_to do |format|
      format.html { redirect_to [:admin, @arret_travail], notice: 'Arret a été  supprimé avec succés.' }
      format.json { head :no_content }
    end
  end

  def show_recu
    respond_to do |format|
      format.html
      format.pdf do
        render pdf: "Reçu paiement indemnité No. #{@at_decompte.id}",
               page_size: 'A4',
               template: "admin/at_decomptes/show_recu.html.erb",
               layout: "pdf.html",
               orientation: "Landscape",
               lowquality: true,
               zoom: 1,
               pi: 75
      end
    end
  end

  def rejeter
    @at_decompte.update(at_decompte_rejete_params.merge(date_rejet: DateTime.now, etat: :rejete, rejete_par: current_user))
    redirect_to [:admin, @arret_travail, @at_decompte], notice: 'Arret a été rejeté avec succés.'
  end

  def convoquer
    @at_decompte.update(at_decompte_convocation_params.merge(convoquer_par: current_user))
    redirect_to [:admin, @arret_travail, @at_decompte], notice: 'Convocation a été bien enregistré.'
  end

  private

  def set_at_decompte
    @at_decompte = AtDecompte.find(params[:id] || params[:at_decompte_id])
  end

  def at_decompte_params
    params.require(:at_decompte).permit(:date_debut, :nombre_jour, :arret_travail_id, :certificat_medical)
  end

  def at_decompte_rejete_params
    params.require(:at_decompte).permit(:motif_rejet)
  end

  def at_decompte_convocation_params
    params.require(:at_decompte).permit(:motif_convocation, :date_convocation)
  end

  def set_arret_travail
    @arret_travail = ArretTravail.find(@at_decompte.arret_travail_id)
  end

end