class Admin::AtLesionsController < Admin::ApplicationController
  before_action :set_at_lesion, except: [:new, :create, :index]
    before_action :set_arret_travail, only: [:destroy, :update, :edit]
    def index
       @at_lesions= AtLesion.all
    end

    def new
      @at_lesion= AtLesion.new
    end
    def show
    #show
  end

    def edit
    end

    def create
      @at_lesion = AtLesion.new(at_lesion_params)
      @at_lesion.arret_travail= @arret_travail
      @at_lesion.etat = :creation
      if @at_lesion.save
        redirect_to [:admin, @at_lesion], notice: 'Arret a été ajoutes avec succés.'
      else
        render :new
      end
    end

    def update
      @arret_travail = ArretTravail.find(@at_lesion.arret_travail_id)
      if @at_lesion.update(at_lesion_params)
        puts "PARAM",at_lesion_params
        redirect_to [:admin, @arret_travail], notice: 'Lésion a été bien mise à jour.'
      else
        render :edit
      end
    end
  # DELETE /admin/at_frais_engage/1
  # DELETE /admin/at_frais_engage/1.json
  def destroy
    @at_lesion.destroy
    respond_to do |format|
      format.html { redirect_to [:admin, @arret_travail], notice: 'Lésion a été  supprimée avec succés.' }
      format.json { head :no_content }
    end
  end



  private
  def set_at_lesion
    @at_lesion = AtLesion.find(params[:id] || params[:at_lesion_id])
  end

  def at_lesion_params
    params.require(:at_lesion).permit(:nature_lesion, :code_nature_lesion,:siege_lesion,:code_siege_lesion, :arret_travail_id)
  end
  
  def set_arret_travail
    @arret_travail = ArretTravail.find(@at_lesion.arret_travail_id)
  end

end