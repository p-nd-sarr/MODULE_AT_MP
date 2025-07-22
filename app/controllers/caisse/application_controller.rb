class Caisse::ApplicationController < ApplicationController
  before_action :authenticate_user!
  before_action :only_caissier!
end