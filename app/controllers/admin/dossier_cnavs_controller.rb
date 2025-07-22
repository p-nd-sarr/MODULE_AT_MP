class Admin::DossierCnavsController < Admin::ApplicationController
  # before_action :set_dossier_cnav, only: [:show, :edit, :update, :destroy]
  before_action :set_dossier_cnav, except: [:index, :new, :create, :en_attente, :ajoutee]
  before_action :can_create?, only: [:new, :create]

  # GET /dossier_cnavs
  # GET /dossier_cnavs.json
  def index
    #@dossier_cnavs = DossierCnav.all
    @q = DossierCnav.visible_for_admins.ransack(params[:q])
    @dossier_cnavs = @q.result.order('created_at desc').page(params[:page]).per(100)
  end

  def en_attente
    @dossier_cnavs = DossierCnav.en_attente.page(params[:page]).per(100)
    # render :index
  end

  def ajoutee
    @dossier_cnavs = current_user.dossier_cnav_crees.page(params[:page]).per(100)
  end

  # GET /dossier_cnavs/1
  # GET /dossier_cnavs/1.json
  def show

    @controleurs = User.controleur_css.where.not(id: @dossier_cnav.ajoute_par.id) # avoir la liste des gestionnaires
  end

  # GET /dossier_cnavs/new
  def new
    @dossier_cnav = DossierCnav.new
  end

  # GET /dossier_cnavs/1/edit
  def edit
  end

  # POST /dossier_cnavs
  # POST /dossier_cnavs.json
  def create
    @dossier_cnav = DossierCnav.new(dossier_cnav_params)
    @dossier_cnav.ajoute_par = current_user
    @dossier_cnav.etat = :creation

    if @dossier_cnav.save
      redirect_to [:admin, @dossier_cnav], notice: 'Le dossier est créé.'
    else
      render :new
    end

  end

  # PATCH/PUT /dossier_cnavs/1
  # PATCH/PUT /dossier_cnavs/1.json
  def update
    if @dossier_cnav.update(dossier_cnav_params)
      #@dossier_cnav.etat_civil_demandeur_valid!(false)
      redirect_to [:admin, @dossier_cnav], notice: 'Le dossier est bien mis à jour.'
    else
      render :edit
    end

  end

  # DELETE /dossier_cnavs/1
  # DELETE /dossier_cnavs/1.json
  def destroy
    @dossier_cnav.destroy
    respond_to do |format|
      format.html { redirect_to [:admin, @dossier_cnav], notice: 'Le dossier est bien supprimé.' }
      format.json { head :no_content }
    end
  end

  def historique_dossier
    @dossier_cnav = DossierCnav.find(params[:dossier_cnav_id])

    render template: "/admin/dossier_cnavs/historique_dossier"
  end

  def charger

  end

  def import
    user_id = current_user.id

    puts user_id
    if params[:file].nil?
      redirect_to admin_dossier_cnav_path(@dossier_cnav), :alert => "Fichier introuvable"
    else
      DossierCnav.my_import(params[:file], user_id, @dossier_cnav)

      redirect_to admin_dossier_cnav_allocataire_cnavs_path(@dossier_cnav), notice: "Fichier importé avec succés"
    end

  end

  def soumettre
    if @dossier_cnav.creation?
      @dossier_cnav.etat = :soumis
      @dossier_cnav.date_soumission = Date.today
      @dossier_cnav.ajoute_par = current_user
      @dossier_cnav.traite_le = DateTime.now
      @dossier_cnav.save
      redirect_to [:admin, @dossier_cnav], notice: 'Le dossier est soumis !'
    else
      redirect_to [:admin, @dossier_cnav]
    end
  end

  def liquider_allocataires
    @allocataire_cnavs = @dossier_cnav.allocataire_cnavs.creation

    annee = Date.today.year
    nbre = @dossier_cnav.allocataire_cnavs.soumis.count

    @allocataire_cnavs.each do |allocataire_cnav|
      allocataire_cnav.etat = :soumis
      nbre += 1
      allocataire_cnav.date_soumission = Date.today

      num_liq = @dossier_cnav.mois.nil? ? DossierCnav.human_enum_name(:trimestre, @dossier_cnav.trimestre) + "Trim/" + "#{annee}/" + nbre.to_s + "Liq" : DossierCnav.human_enum_name(:mois, @dossier_cnav.mois) + "/" + "#{annee}/" + nbre.to_s + "Liq"
      allocataire_cnav.numero_liquidation = num_liq

      allocataire_cnav.save
    end

    @dossier_cnav.etat = :soumis
    @dossier_cnav.save
    puts "AAAAAAAAAAAAAAAAAAA" + @dossier_cnav.etat

    flash[:notice] = 'Liquidation collective réussie.'
    redirect_to admin_dossier_cnav_allocataire_cnavs_path(@dossier_cnav)

  end

  def supprimer_allocataires
    @allocataire_cnavs = @dossier_cnav.allocataire_cnavs.creation

    @allocataire_cnavs.each do |allocataire_cnav|
      allocataire_cnav.destroy
    end

    flash[:notice] = 'Suppression de la liste réussie.'
    redirect_to admin_dossier_cnav_allocataire_cnavs_path(@dossier_cnav)

  end

  def valider_allocataires
    @allocataire_cnavs = @dossier_cnav.allocataire_cnavs.valide_liquidation

    @allocataire_cnavs.each do |allocataire_cnav|
      allocataire_cnav.etat = :valide
      allocataire_cnav.valide!
      allocataire_cnav.traite_par = current_user
      allocataire_cnav.traite_le = DateTime.now
      allocataire_cnav.date_validation = Date.today

      allocataire_cnav.save
    end

    @dossier_cnav.etat = :valide
    @dossier_cnav.save

    flash[:notice] = 'Validation collective réussie.'
    redirect_to admin_dossier_cnav_allocataire_cnavs_path(@dossier_cnav)
  end

  def valider_liquid_allocataires
    @allocataire_cnavs = @dossier_cnav.allocataire_cnavs.soumis

    @allocataire_cnavs.each do |allocataire_cnav|
      allocataire_cnav.etat = :valide_liquidation
      allocataire_cnav.valide_liquidation!
      allocataire_cnav.valider_liq_par = current_user
      allocataire_cnav.valider_liq_le = DateTime.now

      allocataire_cnav.save
    end

    @dossier_cnav.etat = :valide_liquidation
    @dossier_cnav.save

    puts "VALIDATION SALOUM : " + DossierCnav.human_enum_name(:etat, @dossier_cnav.etat)

    flash[:notice] = 'Validation collective liquidation réussie.'
    redirect_to admin_dossier_cnav_allocataire_cnavs_path(@dossier_cnav)
  end

  def valider_inspec_allocataires
    @allocataire_cnavs = @dossier_cnav.allocataire_cnavs.valide

    @allocataire_cnavs.each do |allocataire_cnav|
      # allocataire_cnav.etat = :valide_inspection
      allocataire_cnav.valide_inspection!
      allocataire_cnav.valider_insp_par = current_user
      allocataire_cnav.valider_insp_le = DateTime.now

      allocataire_cnav.save

      # GENERATION FACTURE CNAV
      allocataire_cnav.generer_facture
    end

    @dossier_cnav.etat = :valide_inspection
    @dossier_cnav.save

    flash[:notice] = 'Inspection : Validation collective réussie.'
    redirect_to admin_dossier_cnav_allocataire_cnavs_path(@dossier_cnav)
  end

  def soumission_form; end

  def rapport_controle_soumettre

    if @dossier_cnav.update(dossier_cnav_params.merge(date_rapport: DateTime.now, date_rapport_joint: DateTime.now))
      redirect_to [:admin, @dossier_cnav], notice: 'Rapport enregistré.'
    else
      render :rapport_controle_form
    end

  end

  def rapport_controle_form; end

  def retour
    @dossier_cnav = DossierCnav.new(id: params[:dossier_cnav_id])
  end

  def retour_process
    if @dossier_cnav.soumis?
      @dossier_cnav.update(dossier_cnav_retour_params.merge(ajoute_par: current_user, traite_le: DateTime.now, date_soumission: nil))
      @dossier_cnav.retour_creation!
      redirect_to [:admin, @dossier_cnav], notice: 'Le dossier est retourné avec succés !'
    end
  end

  def valider
    @dossier_cnav.valide!
    @dossier_cnav.traite_par = current_user
    @dossier_cnav.traite_le = DateTime.now
    @dossier_cnav.save
    redirect_to [:admin, @dossier_cnav], notice: 'Le dossier est validé !'
  end

  def rejeter; end

  def rejeter_create
    if @dossier_cnav.update(dossier_cnav_rejet_params.merge(etat: :rejete, traite_par: current_user,
                                                            traite_le: DateTime.now))
      redirect_to admin_cnavs_path, notice: 'Demande traitée.'
    else
      flash[:error] = 'Une erreur est survenue lors du traitement'
      render :rejeter
    end
  end

  def dossier_cnav_retour_params
    params.require(:dossier_cnav).permit(:motif_retour)
  end

  def dossier_cnav_rejet_params
    params.require(:dossier_cnav).permit(:motif_rejet)
  end

  private

  # Use callbacks to share common setup or constraints between actions.
  def set_dossier_cnav
    @dossier_cnav = DossierCnav.find(params[:id] || params[:dossier_cnav_id])

    #  @dossier_cnav = DossierCnav.visible_for_admins.find(params[:id] || params[:dossier_cnav_id])
    # rescue ActiveRecord::RecordNotFound => e
    #  @dossier_cnav = current_user.dossier_cnav_crees.find(params[:id] || params[:dossier_cnav_id])
  end

  # Never trust parameters from the scary internet, only allow the white list through.
  def dossier_cnav_params
    params.require(:dossier_cnav).permit(:numero_dossier, :date_ouverture, :etat, :mois, :annee,
                                         :motif_rejet, :date_soumission, :soumis_par_id, :date_validation,
                                         :valide_par_id, :ajoute_par_id, :traite_le, :traite_par_id,
                                         :user_id, :type_convention, :usage, :trimestre)
  end

  # def dossier_cnav_affecter_controleur_params
  #  params.require(:dossier_cnav).permit(:affectation_controleur, :commentaire_affectation_controleur)
  # end

  def can_create?
    unless (current_user.gestionnaire_compte_allocataire? or current_user.chef_section_liquidation?)
      flash[:error] = 'Seul les gestionnaires de compte allocataire peuvent accéder à cette ressource.'
      redirect_back(fallback_location: root_path)
    end
  end
end
