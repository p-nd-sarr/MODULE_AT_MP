class Admin::RentiersController < Admin::ApplicationController
  before_action :set_rentier, except: [:new, :create, :index, :en_attente_validation, :en_attente_activation]
    #before_action :set_arret_travail, only: [:destroy, :update, :edit]

    def index
       @rentiers= Rentier.all
    end

    def en_attente_validation
      @rentiers = Rentier.en_attente_validation.page(params[:page]).per(100)
    end

    def en_attente_activation
      @rentiers = Rentier.en_attente_activation.page(params[:page]).per(100)
    end

    def new
      @rentier= Rentier.new
    end

    def show
      #show
    end

    def edit
    end

    def create
      @rentier = Rentier.new(rentier_params)
      @rentier.arret_travail= @arret_travail
      if @rentier.save
        redirect_to [:admin, @rentier], notice: 'Avi a été ajoutes avec succés.'
      else
        render :new
      end
    end

    def update
      if @rentier.update(rentier_params)
        redirect_to [:admin, @rentier], notice: 'at_avi a été bien mise à jour.'
      else
        render :edit
      end
    end


  # DELETE /admin/at_frais_engage/1
  # DELETE /admin/at_frais_engage/1.json
  def destroy
    @rentier.destroy
    respond_to do |format|
      format.html { redirect_to [:admin, @rentier], notice: 'rentier a été  supprimée avec succés.' }
      format.json { head :no_content }
    end
  end

  def valider
      @rentier.etat = :en_attente_activation
      @rentier.date_activation_dir_at = Date.today
      if @rentier.save
        redirect_to admin_rentiers_path, notice: 'Rentier activé avec succés.'
      end
  end

  def activer
    @rentier.etat = :actif
    @rentier.date_activation_dg = Date.today
    if @rentier.save
      redirect_to admin_rentiers_path, notice: 'Rentier validé avec succés.'
    end
  end


  def rejeter
    if @rentier.update(rentier_rejet_params.merge(etat: :rejete,
      rejete_par: current_user,
      date_rejet: DateTime.now))
      redirect_to [:admin, @rentier], notice: 'Rentier rejeté.'
    else
      flash[:error] = 'Une erreur est survenue lors du traitement'
      redirect_to [:admin, @rentier]
    end

  end



  private

  def set_rentier
    @rentier = Rentier.find(params[:id] || params[:rentier_id])
  end

  def rentier_rejet_params
    params.require(:rentier).permit(:motif_rejet)
  end



end