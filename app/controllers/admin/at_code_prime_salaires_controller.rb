class Admin::AtCodePrimeSalairesController < Admin::ApplicationController
  #before_action :only_admin!
  before_action :set_at_code_prime_salaire, only: [:show, :edit, :update, :destroy]

  # GET /admin/at_code_prime_salaires
  # GET /admin/at_code_prime_salaires.json
  def index
    @at_code_prime_salaires = AtCodePrimeSalaire.all.order(code: :asc)
  end

  # GET /admin/at_code_prime_salaires/1
  # GET /admin/at_code_prime_salaires/1.json
  def show
    #show
  end

  # GET /admin/at_code_prime_salaires/new
  def new
    @at_code_prime_salaire = AtCodePrimeSalaire.new
  end

  # GET /admin/at_code_prime_salaires/1/edit
  def edit
    #edit
  end

  # POST /admin/at_code_prime_salaires
  # POST /admin/at_code_prime_salaires.json
  def create
    @at_code_prime_salaire = AtCodePrimeSalaire.new(at_code_prime_salaire_params)

    if @at_code_prime_salaire.save
      redirect_to [:admin, @at_code_prime_salaire], notice: 'Le composant est créé.'
    else
      render :new
    end

  end

  # PATCH/PUT /admin/at_code_prime_salaires/1
  # PATCH/PUT /admin/at_code_prime_salaires/1.json
  def update
    if @at_code_prime_salaire.update(at_code_prime_salaire_params)
      redirect_to [:admin, @at_code_prime_salaire], notice: 'Le composant est bien mise à jour.'
    else
      render :edit
    end
  end

  # DELETE /admin/at_code_prime_salaires/1
  # DELETE /admin/at_code_prime_salaires/1.json
  def destroy
    puts "OKKK", @at_code_prime_salaire
    @at_code_prime_salaire.destroy
    respond_to do |format|
      format.html { redirect_to [:admin, @at_code_prime_salaire], notice: 'Composant bien supprimé.' }
      format.json { head :no_content }
    end
  end

  private
    # Use callbacks to share common setup or constraints between actions.
    def set_at_code_prime_salaire
      @at_code_prime_salaire = AtCodePrimeSalaire.find(params[:id] || params[:at_code_prime_salaire_id])
    end

    # Never trust parameters from the scary internet, only allow the white list through.
    def at_code_prime_salaire_params
      params.require(:at_code_prime_salaire).permit(:code, :designation, :prise_en_compte)
    end
end
