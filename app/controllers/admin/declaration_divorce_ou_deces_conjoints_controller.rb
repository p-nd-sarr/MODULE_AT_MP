class Admin::DeclarationDivorceOuDecesConjointsController < ApplicationController
  before_action :set_declaration_divorce_ou_deces_conjoint, only: [:show, :edit, :update, :destroy]

  # GET /declaration_divorce_ou_deces_conjoints
  # GET /declaration_divorce_ou_deces_conjoints.json
  def index
    @q = DeclarationDivorceOuDecesConjoint.all.ransack(params[:q])
    @declaration_divorce_ou_deces_conjoints = @q.result.order('prenom_conjoint asc')
    @declaration_divorce_ou_deces_conjoints = @q.result.order('prenom_conjoint asc').page(params[:page]).per(100) unless params[:format] == 'xlsx'
  end

  # GET /declaration_divorce_ou_deces_conjoints/1
  # GET /declaration_divorce_ou_deces_conjoints/1.json
  def show
    #show
  end

  # GET /declaration_divorce_ou_deces_conjoints/new
  def new
    @declaration_divorce_ou_deces_conjoint = DeclarationDivorceOuDecesConjoint.new
  end

  # GET /declaration_divorce_ou_deces_conjoints/1/edit
  def edit
    @conjoints = Conjoint.where(numero_affiliation: params[:numero_affiliation])
  end

  # POST /declaration_divorce_ou_deces_conjoints
  # POST /declaration_divorce_ou_deces_conjoints.json
  def create
    @declaration_divorce_ou_deces_conjoint = DeclarationDivorceOuDecesConjoint.new(declaration_divorce_ou_deces_conjoint_params)
    unless @declaration_divorce_ou_deces_conjoint.conjoint.nil?
      if @declaration_divorce_ou_deces_conjoint.save
        redirect_to [:admin, @declaration_divorce_ou_deces_conjoint], notice: 'Declaration créer avec succés.'
      else
        render :new
      end
    else
      flash[:error] = 'Veuillez choisir un conjoint.'
      render :new
    end
  end

  # PATCH/PUT /declaration_divorce_ou_deces_conjoints/1
  # PATCH/PUT /declaration_divorce_ou_deces_conjoints/1.json
  def update
      if @declaration_divorce_ou_deces_conjoint.update(declaration_divorce_ou_deces_conjoint_params)
        redirect_to [:admin, @declaration_divorce_ou_deces_conjoint], notice: 'Declaration a été mise à jour.'
      else
        render :edit
      end
  end

  # DELETE /declaration_divorce_ou_deces_conjoints/1
  # DELETE /declaration_divorce_ou_deces_conjoints/1.json
  def destroy
    @declaration_divorce_ou_deces_conjoint.destroy
    redirect_to admin_declaration_divorce_ou_deces_conjoints_path, notice: 'Declaration supprimé avec succés.'
  end

  private
    # Use callbacks to share common setup or constraints between actions.
    def set_declaration_divorce_ou_deces_conjoint
      @declaration_divorce_ou_deces_conjoint = DeclarationDivorceOuDecesConjoint.find(params[:id] || params[:numero_affiliation])
    end

    # Never trust parameters from the scary internet, only allow the white list through.
    def declaration_divorce_ou_deces_conjoint_params
      params.require(:declaration_divorce_ou_deces_conjoint).permit(:numero_affiliation, :prenom_salarie, :nom_salarie, :status_with_conjoint,
                            :prenom_conjoint, :nom_conjoint, :type_piece, :numero_piece_conjoint, :piece_jointe, :conjoint_id, :date_declaration)
    end
end