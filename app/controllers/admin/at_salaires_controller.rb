class Admin::AtSalairesController < Admin::ApplicationController
  before_action :set_at_salaire, except: [:new, :create, :index]
    before_action :set_at_consolidation, only: [:destroy, :update, :edit]
    before_action :set_at_rente_famille, only: [:destroy, :update, :edit]
    def index
       @at_salaires= AtSalaire.all
    end

    def new
      @at_salaire= AtSalaire.new
      @at_salaire.at_code_prime_salaires = AtCodePrimeSalaire.new
    end
    def show
      @at_salaire.at_code_prime_salaires = AtCodePrimeSalaire.new
    end

    def edit
    end

    def create
      @at_salaire = AtSalaire.new(at_salaire_params)
      @at_salaire.at_consolidation = @at_consolidation
      
      if @at_salaire.save
        redirect_to [:admin, @at_salaire], notice: 'Arret a été ajoutes avec succés.'
      else
        render :new
      end
    end

    def update
      if @at_salaire.update(at_salaire_params)
        unless @at_consolidation.nil?
          redirect_to [:admin, @at_consolidation], notice: 'Salaire est bien mise à jour.'
        else
          redirect_to [:admin, @at_rente_famille], notice: 'Salaire est bien mise à jour.'
        end
      else
        render :edit
      end
    end
  # DELETE /admin/at_frais_engage/1
  # DELETE /admin/at_frais_engage/1.json
  def destroy
    @at_salaire.destroy
    respond_to do |format|
      format.html { redirect_to [:admin, @at_consolidation], notice: 'Arret a été  supprimée avec succés.' }
      format.json { head :no_content }
    end
  end



  private
  def set_at_salaire
    @at_salaire = AtSalaire.find(params[:id] || params[:at_salaire_id])
  end

  def at_salaire_params
    params.require(:at_salaire).permit(:mois, :montant, :at_consolidation_id)
  end
  def set_at_consolidation
    unless @at_salaire.at_consolidation_id.nil?
      @at_consolidation = AtConsolidation.find(@at_salaire.at_consolidation_id)
    end
  end
  def set_at_rente_famille
    unless @at_salaire.at_rente_famille_id.nil?
      @at_rente_famille = AtRenteFamille.find(@at_salaire.at_rente_famille_id)
    end
  end
  
end