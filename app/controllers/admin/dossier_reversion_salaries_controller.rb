class Admin::DossierReversionSalariesController < ApplicationController
  before_action :set_dossier_reversion_salarie, only: [:show, :edit, :update, :destroy, :est_eligible, :pas_eligible, :soumettre, :instruire, :liquider, :valider, :rejeter, :valider_recapitulatif, :affecter_allocataire,
                                                    :valider_dossier, :soumettre_recap, :valider_recap, :etat_ayant_droit_valide,:documents_valide,:soumettre_dossier]

  def index
    @dossier_reversion_salaries = DossierReversionSalary.all
  end

  def show
    @gestionnaires = User.gestionnaire_compte_allocataire # avoir la liste des gestionnaires
    @reversion_veuve_salarie = BaseReversionSalary.find(@dossier_reversion_salarie.base_reversion_salary_id)
  end

  def est_eligible
      if @dossier_reversion_salarie.peut_etre_eligible?
        
        @dossier_reversion_salarie.update(eligible: true)
      else
        flash[:error] = "Cet ayant droit n'est pas éligible"
      end
    redirect_to [:admin, @dossier_reversion_salarie]
  end
  
  def soumettre_recap
    @dossier_reversion_salarie.etat=:recap_soumis
    @dossier_reversion_salarie.valider_par = current_user
    @dossier_reversion_salarie.valider_le = DateTime.now
    @dossier_reversion_salarie.save
    @dossier_reversion_salarie.create_allocataire
    redirect_to [:admin, @dossier_reversion_salarie], notice: 'Recap soumis avec succés'
  end

  def valider_recap
    @dossier_reversion_salarie.etat=:recap_valide
    @dossier_reversion_salarie.valider_par = current_user
    @dossier_reversion_salarie.valider_le = DateTime.now
    @dossier_reversion_salarie.save
    @dossier_reversion_salarie.create_allocataire
    redirect_to [:admin, @dossier_reversion_salarie], notice: 'Recap validé avec succés'
  end

  def valider_dossier
      @dossier_reversion_salarie.etat=:valide
      @dossier_reversion_salarie.valider_par = current_user
      @dossier_reversion_salarie.valider_le = DateTime.now
      @dossier_reversion_salarie.save
      @dossier_reversion_salarie.create_allocataire
      redirect_to [:admin, @dossier_reversion_salarie], notice: 'Dossier validé avec succés'
  end

  def update
    respond_to do |format|
      if @dossier_reversion_salarie.update(dossier_reversion_salarie_veuve_params.merge(etat: :complete))
        @dossier_reversion_salarie.etat= :complete
        format.html { redirect_to [:admin, @dossier_reversion_salarie], notice: 'Reversion veuve was successfully updated.' }
        format.json { render :show, status: :ok, location: @dossier_reversion_salarie }
      else
        format.html { render :edit }
        format.json { render json: @dossier_reversion_salarie.errors, status: :unprocessable_entity }
      end
    end
  end

  def destroy
    @dossier_reversion_salarie.destroy
    @reversion_veuve_salarie = BaseReversionSalary.find(@dossier_reversion_salarie.base_reversion_salary_id)
    respond_to do |format|
      format.html { redirect_to [:admin, @reversion_veuve_salarie], notice: 'Dossier reversion  supprimé avec succés.' }
      format.json { head :no_content }
    end
  end

  def pas_eligible
    @dossier_reversion_salarie.update(eligible: false)
    redirect_to [:admin, @dossier_reversion_salarie]
  end


  def etat_ayant_droit_valide
    @dossier_reversion_salarie.etat_ayant_droit_valide!
    redirect_to [:admin, @dossier_reversion_salarie]
  end

  def documents_valide
    unless @dossier_reversion_salarie.documents_valide!
      flash[:error] = "Veuillez déposer tous les documents requis avant la validation"
    end
    redirect_to [:admin, @dossier_reversion_salarie]
  end

  def soumettre_dossier
    @dossier_reversion_salarie.update(etat: :soumis)
    redirect_to [:admin, @dossier_reversion_salarie]
  end

  def lettre_notification1
    @dossier_reversion_salarie = DossierReversionSalary.find(params[:id] || params[:dossier_reversion_salary_id])
    @reversion_veuve_salarie = BaseReversionSalary.find(@dossier_reversion_salarie.base_reversion_salary_id)
    respond_to do |format|
      format.html
      format.pdf do
        render pdf: "lettre notification n°. #{@dossier_reversion_salarie.id}",
               page_size: 'A4',
               template: "admin/dossier_reversion_salaries/lettre_notification1.html.erb",
               layout: "pdf.html",
               orientation: "Landscape",
               lowquality: true,
               zoom: 1,
               pi: 75
      end
    end
  end
 
  def new
      @dossier_reversion_salarie = DossierReversionSalary.new
    end
  end

  def edit

    @reversion_veuve_salarie = BaseReversionSalary.find(@dossier_reversion_salarie.base_reversion_salary_id)
  end

  def create
    @dossier_reversion_salarie = DossierReversionSalary.new(dossier_reversion_salarie_params)
    @dossier_reversion_salarie.numero_allocataire = @allocataire.numero_allocataire
    @dossier_reversion_salarie.ajoute_par = current_user
    @dossier_reversion_salarie.ajouter_le = DateTime.now

    respond_to do |format|
      if @dossier_reversion_salarie.save
        format.html { redirect_to [:admin, @dossier_reversion_salarie], notice: 'Reversion veuve was successfully created.' }
        format.json { render :show, status: :created, location: @dossier_reversion_salarie }
      else
        format.html { render :new }
        format.json { render json: @dossier_reversion_salarie.errors, status: :unprocessable_entity }
      end
    end
  end

  def destroy
    @reversion_veuve.destroy
    respond_to do |format|
      format.html { redirect_to [:admin, @dossier_reversion_salaries], notice: 'Reversion veuve was successfully destroyed.' }
      format.json { head :no_content }
    end
  end

  def rejeter
    if @dossier_reversion_salarie.liquide?
      @dossier_reversion_salarie.est_rejete!
      @dossier_reversion_salarie.valider_par = current_user
      @dossier_reversion_salarie.valider_le = DateTime.now
      @dossier_reversion_salarie.save
      redirect_to [:admin,@dossier_reversion_salarie], notice: 'Dossier validé avec succés'
    else
      redirect_to [:admin, @dossier_reversion_salarie]
    end
  end
  private

  def set_dossier_reversion_salarie
    @dossier_reversion_salarie = DossierReversionSalary.find(params[:id] || params[:dossier_reversion_salary_id])
  end

  def dossier_reversion_salarie_veuve_params
    params.require(:dossier_reversion_salary).permit(:prenom, :nom, :date_naissance, :lieu_naissance, :adresse,
                                            :adresse_reception_allocation, :mode_paiement,
                                            :compte_bancaire_nom_banque, :compte_bancaire_code_banque,
                                            :compte_bancaire_code_guichet, :compte_bancaire_numero_compte,
                                            :type_ayant_droit, :conjoint_id, :enfant_id, :nom_tuteur, :prenom_tuteur, :phone, :email)
  end


  def dossier_reversion_salarie_affecter_allocataire_params
    params.require(:reversion_veuve).permit(:affecter_a)
  end

