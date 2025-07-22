class Employer::ServicesController < Employer::ApplicationController
  def index
    @ninea= current_user.ninea
    @nom= current_user.nom
    @immatriculation = current_user.num_immatriculation

  end
end