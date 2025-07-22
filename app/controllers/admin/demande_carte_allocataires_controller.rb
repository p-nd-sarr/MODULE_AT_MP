class Admin::DemandeCarteAllocatairesController < ApplicationController
  before_action :set_admin_demande_carte_allocataire, only: %i[ show edit update destroy imprimer ]

  # GET /admin/demande_carte_allocataires or /admin/demande_carte_allocataires.json
  def index
    @q = DemandeCarteAllocataire.all.ransack(params[:q])

    @admin_demande_carte_allocataires = @q.result.includes(:allocataire).order('created_at desc')


    if params[:format] == 'xlsx'
      response.headers['Content-Disposition'] = 'attachment; filename=' "demandes_cartes_#{Date.today.strftime('%Y_%m_%d')}.xlsx" ''
      render :liste
    else
      @admin_demande_carte_allocataires = @admin_demande_carte_allocataires.page(params[:page]).per(100)
    end
  end

  # GET /admin/demande_carte_allocataires/1 or /admin/demande_carte_allocataires/1.json
  def show
  end

  def imprimer
    @demande = @admin_demande_carte_allocataire
    respond_to do |format|
      format.html
      format.pdf do
        render pdf: "Carte allocataire #{@admin_demande_carte_allocataire.numero_document}",
               page_size: 'A4',
               template: 'admin/demande_carte_allocataires/imprimer.html.erb',
               layout: 'pdf.html',
               # orientation: 'Landscape',
               lowquality: true,
               zoom: 1,
               pi: 75
      end
    end
  end

  # GET /admin/demande_carte_allocataires/new
  def new
    @admin_demande_carte_allocataire = DemandeCarteAllocataire.new
    @allocataire = Allocataire.find_by(id: params[:allocataire_id])
    if @allocataire.nil?
      redirect_to admin_allocataires_path, notice: "Allocataire introuvable, merci de choisir un allocataire et cliquer sur le bouton 'Ajouter Demande Carte'"
      return
    end
    if @allocataire.demande_carte_allocataire.present?
      redirect_to admin_demande_carte_allocataire_path(@allocataire.demande_carte_allocataire)
      return
    end
    @admin_demande_carte_allocataire.allocataire = @allocataire
    @admin_demande_carte_allocataire.prenom = @allocataire.prenom.strip.squeeze(' ') unless @allocataire.prenom.nil?
    @admin_demande_carte_allocataire.nom = @allocataire.nom.strip.squeeze(' ') unless @allocataire.nom.nil?
    @admin_demande_carte_allocataire.date_naissance = @allocataire.date_naissance
    @admin_demande_carte_allocataire.nin = @allocataire.numero_identification_nationale
    @admin_demande_carte_allocataire.telephone = @allocataire.telephone
    @admin_demande_carte_allocataire.email = @allocataire.email
    @admin_demande_carte_allocataire.adresse = "#{@allocataire.adresse_rue} #{@allocataire.adresse_ville}".squeeze(' ')
    @admin_demande_carte_allocataire.agence_retrait = current_user.admin_agence
  end

  # GET /admin/demande_carte_allocataires/1/edit
  def edit
  end

  # POST /admin/demande_carte_allocataires or /admin/demande_carte_allocataires.json
  def create
    @admin_demande_carte_allocataire = DemandeCarteAllocataire.new(admin_demande_carte_allocataire_params)
    @admin_demande_carte_allocataire.user = current_user
    @admin_demande_carte_allocataire.agence_enregistrement = current_user.admin_agence

    respond_to do |format|
      if @admin_demande_carte_allocataire.save
        format.html { redirect_to admin_demande_carte_allocataire_url(@admin_demande_carte_allocataire), notice: "Demande carte allocataire was successfully created." }
        format.json { render :show, status: :created, location: @admin_demande_carte_allocataire }
      else
        format.html { render :new, status: :unprocessable_entity }
        format.json { render json: @admin_demande_carte_allocataire.errors, status: :unprocessable_entity }
      end
    end
  end

  # PATCH/PUT /admin/demande_carte_allocataires/1 or /admin/demande_carte_allocataires/1.json
  def update
    respond_to do |format|
      if @admin_demande_carte_allocataire.update(admin_demande_carte_allocataire_params)
        format.html { redirect_to admin_demande_carte_allocataire_url(@admin_demande_carte_allocataire), notice: "Demande carte allocataire was successfully updated." }
        format.json { render :show, status: :ok, location: @admin_demande_carte_allocataire }
      else
        format.html { render :edit, status: :unprocessable_entity }
        format.json { render json: @admin_demande_carte_allocataire.errors, status: :unprocessable_entity }
      end
    end
  end

  # DELETE /admin/demande_carte_allocataires/1 or /admin/demande_carte_allocataires/1.json
  def destroy
    @admin_demande_carte_allocataire.destroy

    respond_to do |format|
      format.html { redirect_to admin_demande_carte_allocataires_url, notice: "Demande carte allocataire was successfully destroyed." }
      format.json { head :no_content }
    end
  end

  private
    # Use callbacks to share common setup or constraints between actions.
    def set_admin_demande_carte_allocataire
      @admin_demande_carte_allocataire = DemandeCarteAllocataire.find(params[:id] || params[:demande_carte_allocataire_id])
    end

    # Only allow a list of trusted parameters through.
    def admin_demande_carte_allocataire_params
      params.require(:demande_carte_allocataire).permit(:allocataire_id, :numero_document, :nom, :prenom,
                                                        :date_naissance, :nin, :email, :adresse, :agence_retrait_id,
                                                        :telephone, :document_cni, :photo)
    end
end
