class Admin::AtFraisEngagesController < Admin::ApplicationController
    before_action :set_at_frais_engage, except: [:new, :create, :index]
    before_action :set_arret_travail, only: [:destroy, :update, :edit, :show_recu, :show, :valider_comptable]
    def index
       @at_frais_engages= AtFraisEngage.all
    end

    def new
        @at_frais_engage= AtFraisEngage.new
    end
    def show
    #show
  end

    def edit
    end

    def create
      @at_frais_engage = AtFraisEngage.new(at_frais_engage_params)
      @at_frais_engage.arret_travail= @arret_travail
      if @at_frais_engage.save
        redirect_to [:admin, @at_frais_engage], notice: 'Frais engagé est ajouté avec succés.'
      else
        render :new
      end
    end

    def update
      @arret_travail = ArretTravail.find(@at_frais_engage.arret_travail_id)
      if @at_frais_engage.update(at_frais_engage_params)
        redirect_to [:admin, @arret_travail], notice: 'Frais engagé est bien mis à jour.'
      else
        render :edit
      end
    end

    def liquider
      @arret_travail = @at_frais_engage.arret_travail
      @at_frais_engage.date_liquidation = DateTime.now.to_date.strftime("%d/%m/%Y").to_s
      @at_frais_engage.etat = :liquide
      @at_frais_engage.liquide_par = current_user
      if @at_frais_engage.save
        redirect_to [:admin, @arret_travail], notice: 'Frais engagé a été liquidé avec succés.'
      end
    end

    def valider
      @arret_travail = @at_frais_engage.arret_travail
      @at_frais_engage.date_validation = DateTime.now.to_date.strftime("%d/%m/%Y").to_s
      @at_frais_engage.etat = :valide
      @at_frais_engage.validation_par = current_user
      if @at_frais_engage.save
        redirect_to [:admin, @arret_travail], notice: 'Frais engagé a été validé avec succés.'
      end
    end

    def valider_medecin
      @arret_travail = @at_frais_engage.arret_travail
      @at_frais_engage.date_validation_medecin = DateTime.now.to_date.strftime("%d/%m/%Y").to_s
      @at_frais_engage.etat = :validation_medecin
      @at_frais_engage.validation_medecin_conseil_par = current_user
      if @at_frais_engage.save
        redirect_to [:admin, @arret_travail], notice: 'Frais engagé a été validé par le medecin conseil.'
      end
    end

    def valider_comptable
      ValiderPaiementAtFraisEngagesJob.perform_now(@at_frais_engage, current_user)
      redirect_to [:admin, @arret_travail], notice: 'Frais engagé a été validé par le comptable.'
    end

  # DELETE /admin/at_frais_engage/1
  # DELETE /admin/at_frais_engage/1.json
  def destroy
    @at_frais_engage.destroy
    respond_to do |format|
      format.html { redirect_to [:admin, @arret_travail], notice: 'Frais engage  supprimé avec succés.' }
      format.json { head :no_content }
    end
  end


    def soumettre
      if @at_frais_engage.creation?
        @at_frais_engage.est_soumis!
        @at_frais_engage.date_soumission = DateTime.now
        @at_frais_engage.soumis_par = current_user
        @at_frais_engage.save
        redirect_to at_frais_engage_path(@at_frais_engage), notice: 'Arret travail was successfully submitted.'
      else
        redirect_to [:admin, @at_frais_engage]
      end

    end

    def show_recu
       respond_to do |format|
         format.html
         format.pdf do
           render pdf: "Recu paiement frais engagés No. #{@at_frais_engage.id}",
                  page_size: 'A4',
                  template: "admin/at_frais_engages/show_recu.html.erb",
                  layout: "pdf.html",
                  orientation: "Landscape",
                  lowquality: true,
                  zoom: 1,
                  pi: 75
         end
       end
     end


    def rejeter
      @arret_travail = @at_frais_engage.arret_travail
      @at_frais_engage.update(at_frais_engage_rejete_params.merge(date_rejet: DateTime.now, etat: :rejete, rejete_par: current_user))
      redirect_to [:admin,@arret_travail], notice: 'Frais a été rejeté avec succés.'
    end

    def activer
      
      @arret_travail = @at_frais_engage.arret_travail
      @at_frais_engage.date_activation = DateTime.now.to_date.strftime("%d/%m/%Y").to_s
      @at_frais_engage.etat = :creation
      @at_frais_engage.active_par = current_user
      if @at_frais_engage.save
        redirect_to [:admin, @arret_travail], notice: 'Frais engage a été activé avec succés.'
      end
    end

    private
    def set_at_frais_engage
      @at_frais_engage = AtFraisEngage.find(params[:id] || params[:at_frais_engage_id])
    end

  def at_frais_engage_params
    params.require(:at_frais_engage).permit(:numero,  :prenom, :nom, :type_frais, :rembourse_a_qui,
                                                 :nature, :date_liquidation,:montant,:remboursement_tiers, :arret_travail_id)
  end

  def set_arret_travail
    @arret_travail = ArretTravail.find(@at_frais_engage.arret_travail_id)
  end

  def at_frais_engage_rejete_params
    params.require(:at_frais_engage).permit(:motif_rejet)
  end

end