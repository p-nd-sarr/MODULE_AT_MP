class Admin::AtIncapacitesController < Admin::ApplicationController
  before_action :set_at_incapacite, except: [:new, :create, :index]
    before_action :set_arret_travail, only: [:destroy, :update, :edit]
    def index
       @at_incapacites= AtIncapacite.all
    end

    def new
        @at_incapacite= AtIncapacite.new
    end
    def show
    #show
  end

    def edit
    end

    def create
      @at_incapacite = AtIncapacite.new(at_at_incapacite_params)
      @at_incapacite.arret_travail= @arret_travail
      if @at_incapacite.save
        redirect_to [:admin, @at_incapacite], notice: 'Incapacité a été ajoutes avec succés.'
      else
        render :new
      end
    end

    def update
      @arret_travail = ArretTravail.find(@at_incapacite.arret_travail_id)
      if @at_incapacite.update(at_incapacite_params)
        redirect_to [:admin, @arret_travail], notice: 'Incapacité a été bien mise à jour.'
      else
        render :edit
      end
    end

    def liquider
      @arret_travail = @at_incapacite.arret_travail
      @at_incapacite.date_liquidation = DateTime.now.to_date.strftime("%d/%m/%Y").to_s
      @at_incapacite.etat = :liquidation
      if @at_incapacite.save
        redirect_to [:admin, @arret_travail], notice: 'Incapacité a été liquidée avec succés.'
      end
    end

    def valider
      @arret_travail = @at_incapacite.arret_travail
      @at_incapacite.date_validation = DateTime.now.to_date.strftime("%d/%m/%Y").to_s
      @at_incapacite.etat = :validation
      if @at_incapacite.save
        redirect_to [:admin, @arret_travail], notice: 'Incapacité a été validée avec succés.'
      end
    end

    def valider_medecin
      @arret_travail = @at_incapacite.arret_travail
      @at_incapacite.date_validation_medecin = DateTime.now.to_date.strftime("%d/%m/%Y").to_s
      @at_incapacite.etat = :validation_medecin
      if @at_incapacite.save
        redirect_to [:admin, @arret_travail], notice: 'Incapacité a été validée par le chef service AT.'
      end
    end

    def valider_comptable
      @arret_travail = @at_incapacite.arret_travail
      @at_incapacite.date_validation_comptable = DateTime.now.to_date.strftime("%d/%m/%Y").to_s
      @at_incapacite.etat = :validation_comptable
      if @at_incapacite.save
        redirect_to [:admin, @arret_travail], notice: 'Incapacité a été validée par le comptable.'
      end
    end

  # DELETE /admin/at_frais_engage/1
  # DELETE /admin/at_frais_engage/1.json
  def destroy
    @at_incapacite.destroy
    respond_to do |format|
      format.html { redirect_to [:admin, @arret_travail], notice: 'Incapacité a été  supprimée avec succés.' }
      format.json { head :no_content }
    end
  end



    private
    def set_at_frais_engage
      @at_incapacite = AtIncapacite.find(params[:id] || params[:at_frais_engage_id])
    end

  def at_frais_engage_params
    params.require(:at_incapacite).permit(:numero,  :prenom, :nom, :type_frais, :rembourse_a_qui,
                                                 :nature, :date_liquidation,:montant, :arret_travail_id)
  end
  def set_arret_travail
    @arret_travail = ArretTravail.find(@at_incapacite.arret_travail_id)
  end

end