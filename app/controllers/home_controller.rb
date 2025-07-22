class HomeController < ApplicationController
  def index
    if user_signed_in?
      if current_user.salarie?
        redirect_to salarie_root_path
      elsif current_user.user_back_office?
        redirect_to admin_root_path
      elsif current_user.employeur?
        redirect_to employer_root_path
      elsif current_user.allocataire?
        redirect_to allocataire_root_path
      elsif current_user.can_show_admin?
        redirect_to admin_root_path
      elsif current_user.chef_agence?
        redirect_to admin_root_path
      elsif current_user.comptable?
        redirect_to admin_root_path
      elsif current_user.user_back_office?
        redirect_to admin_root_path
      elsif current_user.inspection?
        redirect_to admin_root_path
      elsif current_user.consultation?
        redirect_to admin_root_path
      elsif current_user.caissier_ipres?
        redirect_to caisse_root_path
      elsif current_user.agent_direction_juridique?
        redirect_to admin_root_path
      elsif current_user.directeur_juridique?
        redirect_to admin_root_path
      elsif current_user.chef_service_direction_juridique?
        redirect_to admin_root_path
      elsif current_user.chef_service_prest_ext?
        redirect_to admin_root_path
      else
        redirect_to root_path
      end
    end
  end

  def password_update
    @user = User.find(current_user.id)
    if @user.update_with_password(user_password_params)
      sign_in @user, :bypass => true
      flash[:notice] = 'mot de passe modifié'
      redirect_to root_path
    else
      flash[:error] = 'une erreur est survenue lors de la modification du mot de passe'
      render :edit_password
    end
  end

  def edit_password
    @user = current_user
  end

  private

  def user_password_params
    # NOTE: Using `strong_parameters` gem
    params.require(:user).permit(:password, :password_confirmation, :current_password)
  end
end
