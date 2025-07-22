class Admin::AtAvisController < Admin::ApplicationController
  before_action :set_at_avi, except: [:new, :create, :index]
    before_action :set_arret_travail, only: [:destroy, :update, :edit]

    def index
       @at_avis= AtAvi.all
    end

    def new
      @at_avis= AtAvi.new
    end

    def show
      #show
    end

    def edit
    end

    def create
      @at_avi = AtAvi.new(at_avi_params)
      @at_avi.arret_travail= @arret_travail
      if @at_avi.save
        redirect_to [:admin, @at_avi], notice: 'Avi a été ajoutes avec succés.'
      else
        render :new
      end
    end

    def update
     # @arret_travail = ArretTravail.find(@at_avi.arret_travail_id)
      if @at_avi.update(at_avi_params)
        redirect_to [:admin, @arret_travail], notice: 'at_avi a été bien mise à jour.'
      else
        render :edit
      end
    end


  # DELETE /admin/at_frais_engage/1
  # DELETE /admin/at_frais_engage/1.json
  def destroy
    @at_avi.destroy
    respond_to do |format|
      format.html { redirect_to [:admin, @arret_travail], notice: 'avis a été  supprimée avec succés.' }
      format.json { head :no_content }
    end
  end



  private

  def set_at_avi
    @at_avi = AtAvi.find(params[:id] || params[:at_frais_engage_id])
  end

  def at_avi_params
    params.require(:at_avi).permit(:fait_par, :fait_par_profil, :description, :dprp_obligatoire, :medecin_conseil_obligatoire, :arret_travail_id, :avis)
  end

  def set_arret_travail
    @arret_travail = ArretTravail.find(@at_avi.arret_travail_id)
  end

end