class Salarie::IndemniteCongesMaternitesController < Salarie::ApplicationController
  before_action :set_dossier_maternite
  before_action :set_indemnite_conges_maternite, except: [:index, :new, :create]

  def index
    @indemnite_conges_maternites = @dossier_maternite.indemnite_conges_maternites
  end

  def show
    #show
  end

  def new
    @indemnite_conges_maternite = IndemniteCongesMaternite.new
  end

  def edit; end

  def create
    @indemnite_conges_maternite = IndemniteCongesMaternite.new(indemnite_conges_maternite_params)
    @indemnite_conges_maternite.dossier_maternite = @dossier_maternite
    @indemnite_conges_maternite.user = current_user
    @indemnite_conges_maternite.ajoute_par = current_user
    @indemnite_conges_maternite.etat = :creation

    if @indemnite_conges_maternite.save
      redirect_to [:salarie, @dossier_maternite, @indemnite_conges_maternite], notice: 'Indemnite conges maternite was successfully created.'
    else
      render :new
    end
  end

  def update
    if @indemnite_conges_maternite.update(indemnite_conges_maternite_params)
      redirect_to [:salarie, @dossier_maternite, @indemnite_conges_maternite], notice: 'Indemnite conges maternite was successfully updated.'
    else
      render :edit
    end
  end

  def destroy
    @indemnite_conges_maternite.destroy
    redirect_to salarie_dossier_maternite_indemnite_conges_maternites_path, notice: 'Indemnite conges maternite was successfully destroyed.'
  end

  def soumettre
    if @indemnite_conges_maternite.update(soumission_indemnite_conges_maternite_params.merge(etat: :soumis, date_soumission: Date.today))
      redirect_to salarie_dossier_maternite_indemnite_conges_maternites_path(@dossier_maternite), notice: "La demande est soumise."
    else
      render :soumission_form
    end
  end

  def soumission_form; end

  private
  # Use callbacks to share common setup or constraints between actions.
  def set_indemnite_conges_maternite
    @indemnite_conges_maternite = IndemniteCongesMaternite.find(params[:id] || params[:indemnite_conges_maternite_id])
  end

  # Never trust parameters from the scary internet, only allow the white list through.
  def indemnite_conges_maternite_params
    params.require(:indemnite_conges_maternite).permit(:tranche_paiement,:debut_conges, :date_accouchement,
                                                       :date_reprise_service, :attestation_accouchement, :certificat_reprise)
  end

  def set_dossier_maternite
    @dossier_maternite = current_user.dossier_maternites.find(params[:dossier_maternite_id])
  end


  def soumission_indemnite_conges_maternite_params
    params.require(:indemnite_conges_maternite).permit(:condition_1, :condition_2)
  end

  def peut_etre_edite!
    unless @indemnite_conges_maternite.creation?
      flash[:error] = "Vous ne pouvez pas éditer une demande déjà soumise"
      redirect_to [:salarie, @dossier_maternite, @indemnite_conges_maternite]
    end
  end
end