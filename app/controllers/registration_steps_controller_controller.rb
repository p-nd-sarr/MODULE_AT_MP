class RegistrationStepsController < ApplicationController
  include Wicked::Wizard
  steps :numero_css, :ninea, :info_user

  def show
    @user = current_user
    render_wizard
  end

  def after_sign_up_path_for(resource)
    registration_steps_path
  end

  def update
    @user = current_user
    @user.attributes = params[:user]
    render_wizard @user
  end


  def finish_wizard_path
    registration_success_path
  end
end
