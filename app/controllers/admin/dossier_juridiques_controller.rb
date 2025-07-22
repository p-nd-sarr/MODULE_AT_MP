class Admin::DossierJuridiquesController < ApplicationController
  before_action :set_dossier_juridique, only: [:show, :edit, :update, :destroy, :affecter_dossier, :annuler_affectation_dossier, :soumettre, :cloturer, :rejeter, :historique]

  # GET dossier_juridiques
  # GET dossier_juridiques.json
  def index
    @q = DossierJuridique.all.ransack(params[:q])
    @dossier_juridiques = @q.result.order('created_at desc')
    @dossier_juridiques = @q.result.order('created_at desc').page(params[:page]).per(100) unless params[:format] == 'xlsx'
    @admin_type_dossier_juridiques = Admin::TypeDossierJuridique.all
    @agents = User.users_for_type('agent_direction_juridique').en_agence(current_user.agence_id)
  end

  # GET dossier_juridiques/1
  # GET dossier_juridiques/1.json
  def show
    @agents = User.users_for_type('agent_direction_juridique').en_agence(current_user.agence_id)
    @avocats_huissier = AvocatsHuissier.new
    @dossier_juridique_honoraire = DossierJuridiqueHonoraire.new
    @dossier_juridique_acte = DossierJuridiqueActe.new

    @q = @dossier_juridique.avocats_huissiers.ransack(params[:q])
    @avocats_huissiers = @q.result.order('created_at asc').page(params[:page]).per(10)

    @q = @dossier_juridique.dossier_juridique_actes.ransack(params[:q])
    @dossier_juridique_actes = @q.result.order('created_at asc').page(params[:page]).per(10)

    @q = @dossier_juridique.dossier_juridique_honoraires.ransack(params[:q])
    if params[:type_int] == "1"
      @q = @dossier_juridique.dossier_juridique_honoraires.where(avocats_huissier_id: nil).ransack(params[:q])
    elsif params[:type_int] == "2"
      @q = @dossier_juridique.dossier_juridique_honoraires.where(avocats_huissier_id: AvocatsHuissier.avocats.pluck(:id)).ransack(params[:q])
    elsif params[:type_int] == "3"
      @q = @dossier_juridique.dossier_juridique_honoraires.where(avocats_huissier_id: AvocatsHuissier.huissiers.pluck(:id)).ransack(params[:q])
    end
    @dossier_juridique_honoraires = @q.result.order('created_at asc').page(params[:page]).per(10)
  end

  # GET dossier_juridiques/new
  def new
    @dossier_juridique = DossierJuridique.new
    @admin_type_dossier_juridiques = Admin::TypeDossierJuridique.all
  end

  # GET dossier_juridiques/1/edit
  def edit
    @admin_type_dossier_juridiques = Admin::TypeDossierJuridique.all
  end

  # POST /dossier_juridiques
  # POST /dossier_juridiques.json
  def create
    @dossier_juridique = DossierJuridique.new(dossier_juridique_params)
    @dossier_juridique.ajoute_par = current_user
    @dossier_juridique.workflow_state = :creation

    respond_to do |format|
      if @dossier_juridique.save
        format.html { redirect_to admin_dossier_juridique_path(@dossier_juridique), notice: 'Dossier juridique a été créé avec sucès.' }
        format.json { render :show, status: :created, location: @dossier_juridique }
      else
        @admin_type_dossier_juridiques = Admin::TypeDossierJuridique.all
        format.html { render :new }
        format.json { render json: @dossier_juridique.errors, status: :unprocessable_entity }
      end
    end
  end

  # PATCH/PUT /dossier_juridiques/1
  # PATCH/PUT /dossier_juridiques/1.json
  def update
    respond_to do |format|
      if @dossier_juridique.update(dossier_juridique_params)
        format.html { redirect_to admin_dossier_juridique_path(@dossier_juridique), notice: 'Dossier juridique a été modifié avec sucès.' }
        format.json { render :show, status: :ok, location: @dossier_juridique }
      else
        @admin_type_dossier_juridiques = Admin::TypeDossierJuridique.all
        format.html { render :edit }
        format.json { render json: @dossier_juridique.errors, status: :unprocessable_entity }
      end
    end
  end

  # DELETE /dossier_juridiques/1
  # DELETE /dossier_juridiques/1.json
  def destroy
    @dossier_juridique.destroy
    respond_to do |format|
      format.html { redirect_to admin_dossier_juridiques_url, notice: 'Dossier juridique a été supprimé avec sucès.' }
      format.json { head :no_content }
    end
  end

  def historique
    @costs = @dossier_juridique.dossier_juridique_honoraires
    @acts = @dossier_juridique.dossier_juridique_actes
    @q = (@costs + @acts).sort_by { |h| h[:created_at] }.reverse!
    @results = Kaminari.paginate_array(@q).page(params[:page]).per(5)
  end

  def affecter_dossier
    @agent = User.find(params[:agent_id])
    @dossier_juridique.set_as_agent_chosen(@agent.id)
    if @dossier_juridique.creation?
      @dossier_juridique.est_affecte!
    end
    redirect_to admin_dossier_juridique_path(@dossier_juridique), notice: 'L' 'agent a été choisi en tant que titulaire du dossier.'
  end

  def annuler_affectation_dossier
    @agent = User.find(params[:agent_id])
    @dossier_juridique.is_not_agent_chosen_anymore(@agent.id)
    if @dossier_juridique.affectation? and @dossier_juridique.affectation_dossier_juridiques.length == 0
      @dossier_juridique.retour_creation!
    end
    redirect_to admin_dossier_juridique_path(@dossier_juridique), notice: 'L' 'agent a été retiré en tant que titulaire du dossier.'
  end

  def soumettre
    if @dossier_juridique.affectation?
      @dossier_juridique.soumis_par = current_user
      @dossier_juridique.date_soumission = Date.today
      @dossier_juridique.motif_rejet = ''
      @dossier_juridique.date_rejet = nil
      @dossier_juridique.rejete_par = nil
      @dossier_juridique.est_soumis!
      @dossier_juridique.save
    end
    redirect_to admin_dossier_juridique_path(@dossier_juridique), notice: 'Le dossier a été soumis avec succès.'
  end

  def cloturer
    if @dossier_juridique.soumission?
      @dossier_juridique.cloture_par = current_user
      @dossier_juridique.date_cloture = Date.today
      @dossier_juridique.est_cloture!
      @dossier_juridique.save
    end
    redirect_to admin_dossier_juridique_path(@dossier_juridique), notice: 'Le dossier a été soumis avec succès.'
  end

  def rejeter
    if @dossier_juridique.soumission?
      @dossier_juridique.date_rejet = Date.today
      @dossier_juridique.rejete_par = current_user
      @dossier_juridique.update(dossier_juridique_params)
      @dossier_juridique.retour_affectation!
      @dossier_juridique.save
    end

    if @dossier_juridique.save
      redirect_to admin_dossier_juridique_path(@dossier_juridique), notice: 'Le dossier a été rejeté avec succès.'
    end

  end

  private

  # Use callbacks to share common setup or constraints between actions.
  def set_dossier_juridique
    @dossier_juridique = DossierJuridique.find(params[:id] || params[:dossier_juridique_id])
  end

  # Never trust parameters from the scary internet, only allow the white list through.
  def dossier_juridique_params
    params.require(:dossier_juridique).permit(:nom_dossier, :objet_dossier, :description_dossier, :parties, :requerent, :defendeur, :date_debut_contrat, :date_fin_contrat,
                                              :nature_litige, :etat_procedure, :agence_concerne, :direction_concerne, :montant_reclame, :admin_type_dossier_juridique_id, :motif_rejet)

  end
end
