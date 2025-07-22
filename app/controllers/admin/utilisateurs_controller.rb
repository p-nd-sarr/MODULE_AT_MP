class Admin::UtilisateursController < Admin::ApplicationController
  before_action :set_user, only: [:show, :edit, :update, :destroy, :lock, :unlock, :activer, :desactiver]

  def index
    if current_user.admin? or current_user.super_admin?
      @type_profil = params[:type_profil]
      @q = @type_profil.nil? ? User.all.ransack(params[:q]) : User.where(type_profil: @type_profil).ransack(params[:q])
      @users = @q.result
    elsif current_user.gestionnaire_compte_salarie?
      @type_profil = 'salarie'
      @q = User.salarie.ransack(params[:q])
      @users = @q.result
    elsif current_user.gestionnaire_compte_allocataire? or current_user.chef_service_allocation?
      @type_profil = 'allocataire'
      @q = User.allocataire.ransack(params[:q])
      @users = @q.result
    elsif current_user.gestionnaire_compte_employeur?
      @type_profil = 'employeur'
      @q = User.employeur.ransack(params[:q])
      @users = @q.result
    elsif current_user.chef_service_allocation?
      @type_profil = 'gestionnaire_compte_allocataire'
      @q = User.gestionnaire_compte_allocataire.ransack(params[:q])
      @users = @q.result
    else
      @q = User.none.ransack(params[:q])
      @users = @q.result
    end
    @users = @users.order('nom asc').page(params[:page]).per(100)
  end

  def show
    @type_profil = @user.type_profil

    @employeur = Psrm::Employeur.find_by(ancien_num_ipres: @user.num_ipres)
  end

  def new
    @user = User.new

    @agences = Admin::Agence.all
  end

  def edit
    @agences = Admin::Agence.all
  end

  def destroy
    @user.destroy
    redirect_to admin_users_path, notice: 'Le compte est supprimé'
  end

  def lock
    @user.lock_access!
    flash[:notice] = "L'utilisateur est bloqué"
    redirect_to admin_users_path
  end

  def unlock
    @user.unlock_access!
    flash[:notice] = "L'utilisateur est débloqué"
    redirect_to admin_users_path
  end

  def activer
    @user.activer!
    @user.liquidation_retraites = LiquidationRetraite.where(numero_affiliation: @user.numero_salarie)
    @user.activated_by = current_user
    @user.save
    flash[:notice] = 'Le compte est activé'
    redirect_to admin_users_path
  end

  def desactiver
    @user.desactiver!
    flash[:notice] = 'Le compte est désactivé'
    redirect_to admin_users_path
  end

  def create
    @user = User.new(user_params)
    unless current_user.type_profil_he_can_create.include?(@user.type_profil.to_sym)
      redirect_to admin_users_path, alert: "Vous n\'avez pas le droit de créer ce type de profil"
      return
    end

    if @user.super_admin? and User.super_admin.count >= 3
      redirect_to admin_users_path, alert: "Vous ne pouvez pas créer plus de 3 super administrateurs"
      return
    end

    @user.created_by = current_user
    generated_password = ''
    if @user.password.nil?
      generated_password = (('A'..'Z').to_a + ('0'..'9').to_a).shuffle[0..7].join
      @user.password = generated_password
    end

    if @user.save
      UserMailer.new_account(@user, generated_password).deliver_later unless generated_password.empty?
      redirect_to [:admin, @user], notice: 'Utilisateur ajouté. Un mail contenant son mot de passe lui est envoyé'
    else
      @agences = Admin::Agence.all
      render action: 'new'
    end
  end

  def update
    unless current_user.type_profil_he_can_create.include?(@user.type_profil.to_sym)
      redirect_to admin_users_path, alert: "Vous n\'avez pas le droit de modifier ce type de profil"
      return
    end
    previous_email = @user.email
    if @user.update(user_params)
      UserMailer.email_updated(@user, previous_email).deliver_later unless previous_email == @user.email
      redirect_to [:admin, @user], notice: 'Utilisateur modifié.'
    else
      puts @user.errors.messages
      @agences = Admin::Agence.all
      render action: 'edit'
    end
  end

  private

  def set_user
    @user = if current_user.admin? or current_user.super_admin?
              User
            elsif current_user.gestionnaire_compte_salarie?
              User.salarie
            elsif current_user.gestionnaire_compte_allocataire? or current_user.chef_service_allocation?
              User.allocataire
            elsif current_user.gestionnaire_compte_employeur?
              User.employeur
            end.find(params[:id] || params[:user_id])
  end

  def user_params
    params.require(:user).permit(:email, :password, :password_confirmation, :sexe,
                                 :prenom, :nom, :type_profil, :telephone, :numero_salarie, :agence_id)
  end
end
