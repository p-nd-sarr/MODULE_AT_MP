class Admin::ApplicationController < ApplicationController
  before_action :authenticate_user!
  before_action :only_user_back_office!
end