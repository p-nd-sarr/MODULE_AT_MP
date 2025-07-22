class Employer::InformationsController < Employer::ApplicationController
  def index
    @ninea= current_user.ninea
    @nom= current_user.nom
    @num_immatriculation = current_user.num_immatriculation
    @num_css = current_user.num_css
    @num_ipres = current_user.num_ipres
    @telephone = current_user.telephone
    @email = current_user.email

  end
end