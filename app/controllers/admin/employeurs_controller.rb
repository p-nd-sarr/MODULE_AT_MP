class Admin::EmployeursController < ApplicationController
  before_action :set_employeur, only: [:show, :declaration_manquante_charger,
                                       :declaration_manquante_charger_create,
                                       :declaration_manquante_charger_show,
                                       :declaration_manquante_charger_valider,
                                       :declaration_manquante_charger_rejeter]
  before_action :set_declaration_manquante, only: [:declaration_manquante_charger,
                                                   :declaration_manquante_charger_create,
                                                   :declaration_manquante_charger_show,
                                                   :declaration_manquante_charger_valider,
                                                   :declaration_manquante_charger_rejeter]

  def index
    @q = Psrm::Employeur.all.ransack(params[:q])
    @employeurs = @q.result.page(params[:page]).per(100)
  end

  def single_employeur
    @employeur = Psrm::Employeur.find_by(fhnum: params[:numero_employeur])
  end

  def all_employeur
    @q = Psrm::Employeur.all.ransack(params[:q])
    @employeurs = @q.result.order('fhrsoc asc').page(params[:page]).per(100)
  end

  def show
    @q = Psrm::Carriere.where(fhnum: @employeur.fhnum).ransack(params[:q])
    @carrieres = @q.result.order('date_debut_periode_cotisation DESC').page(params[:page]).per(100)
  end

  def declarations
    @ninea = params[:ninea]
    @user = User.find_by(ninea: @ninea)
    @employeur = Psrm::Employeur.find_by(ancien_num_ipres: @user.num_ipres)

    @declarations = Declaration.soumis
    @historique_css_declarations = []

    @historique_ipres_declarations = @employeur.missing_declarations
  end

  def immatriculation
    @ninea = params[:ninea]
    @user = User.find_by(ninea: @ninea)
    @employeur = Psrm::Employeur.find_by(ancien_num_ipres: @user.num_ipres)

    @immatriculation = @user.immatriculation
    @representant = @user.representant_legal

    @salaries = @user.salarie_immatriculations.page(params[:page]).per(10)
  end

  # region gestion des declarations manquantes
  def chargements_edi
    @q = DeclarationChargement.ransack(params[:q])
    @chargements = @q.result
    @chargements = @chargements.includes(:traite_par, :created_by, declaration_salaire_manquante: [:employeur]).order('created_at desc').page(params[:page]).per(100)
  end

  def declarations_manquantes
    @declarations = DeclarationSalaireManquante.all.includes(:employeur).order('created_at desc').page(params[:page]).per(100)
  end

  def declarations_manquantes_new
    @declaration = DeclarationSalaireManquante.new
  end

  def declarations_manquantes_create
    @declaration = DeclarationSalaireManquante.new(declaration_manquante_params)
    if @declaration.save
      redirect_to declarations_manquantes_admin_employeurs_path, notice: 'La déclaration a été créée avec succès'
    else
      render :declarations_manquantes_new
    end
  end

  def declaration_manquante_charger_show
    @declaration_chargement = @declaration_manquante.declaration_chargements.find(params[:id])
  end

  def declaration_manquante_charger_valider
    unless current_user.chef_service_cotisation?
      flash[:error] = "Vous n'avez pas les droits pour effectuer cette action"
      redirect_to admin_employeur_path(@employeur)
      return
    end

    @declaration_chargement = @declaration_manquante.declaration_chargements.find(params[:id])
    if @declaration_chargement.fichier_valide?
      @declaration_chargement.valider(current_user)
      render :declaration_manquante_charger_show, notice: 'La déclaration a été validée avec succès'
    else
      flash[:error] = "Vous ne pouvez pas traiter ce chargement"
      render :declaration_manquante_charger_show
    end
  end

  def declaration_manquante_charger_rejeter
    unless current_user.chef_service_cotisation?
      flash[:error] = "Vous n'avez pas les droits pour effectuer cette action"
      redirect_to admin_employeur_path(@employeur)
      return
    end

    @declaration_chargement = @declaration_manquante.declaration_chargements.find(params[:id])
    if @declaration_chargement.fichier_valide?
      motif_rejet = params[:motif_rejet]
      @declaration_chargement.rejeter(current_user, motif_rejet)
      render :declaration_manquante_charger_show, notice: 'La déclaration a été rejetée avec succès'
    else
      flash[:error] = "Vous ne pouvez pas traiter ce chargement"
      render :declaration_manquante_charger_show
    end
  end

  def declaration_manquante_charger
    unless current_user.gestionnaire_compte_salarie?
      flash[:error] = "Vous n'avez pas les droits pour effectuer cette action"
      redirect_to admin_employeur_path(@employeur)
      return
    end

    if @declaration_manquante.manquante?
      @declaration_chargement = DeclarationChargement.new(declaration_salaire_manquante: @declaration_manquante)
    else
      if @declaration_manquante.chargee?
        @declaration_chargement = @declaration_manquante.declaration_chargements.order('created_at desc').last
        flash[:error] = "La déclaration manquante est déjà chargée"
      else
        @declaration_chargement = @declaration_manquante.declaration_chargements.order('created_at desc').last
        flash[:error] = "Un chargement est déjà en cours de traitement"
      end
      render :declaration_manquante_charger_show
    end
  end

  def declaration_manquante_charger_create
    unless current_user.gestionnaire_compte_salarie?
      flash[:error] = "Vous n'avez pas les droits pour effectuer cette action"
      redirect_to admin_employeur_path(@employeur)
      return
    end

    if @declaration_manquante.manquante?
      @declaration_chargement = DeclarationChargement.new(declaration_chargement_params)
      @declaration_chargement.declaration_salaire_manquante = @declaration_manquante
      @declaration_chargement.created_by = current_user

      if @declaration_chargement.save
        render :declaration_manquante_charger_show, notice: 'La déclaration a été chargée avec succès'
      else
        render :declaration_manquante_charger
      end
    else
      if @declaration_manquante.chargee?
        @declaration_chargement = @declaration_manquante.declaration_chargements.order('created_at desc').last
        flash[:error] = "La déclaration manquante est déjà chargée"
      else
        @declaration_chargement = @declaration_manquante.declaration_chargements.order('created_at desc').last
        flash[:error] = "Un chargement est déjà en cours de traitement"
      end
      render :declaration_manquante_charger_show
    end
  end

  # endregion

  private

  def set_enfant
    @employeur = Psrm::Employeur.find(params[:id])
  end

  def set_employeur
    @employeur = Psrm::Employeur.find(params[:employeur_id] || params[:id])
  end

  def set_declaration_manquante
    @declaration_manquante = @employeur.declaration_salaire_manquantes.find(params[:dsm_id])
  end

  def declaration_chargement_params
    begin
      params.require(:declaration_chargement).permit(:fichier)
    rescue ActionController::ParameterMissing
      ActionController::Parameters.new
    end
  end

  def declaration_manquante_params
    begin
      params.require(:declaration_salaire_manquante).permit(:numero, :raison_sociale, :zone, :adresse, :exercice,
                                                            :regime, :telephone, :effectif, :code_agence)
    rescue ActionController::ParameterMissing
      ActionController::Parameters.new
    end
  end
end
