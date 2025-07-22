class Admin::AssureTpesController < ApplicationController
  before_action :set_admin_bareme_pension, only: [:show]

  def index
    @q = Enrolement::AssureTpe.select(:id, :numero_allocataire, :prenom, :nom, :cdao, :nin, :sexe, :dateInsert).ransack(params[:q])
    @assures = @q.result.order('dateInsert DESC').page(params[:page]).per(150)
  end

  def show
    #show
  end

  private
    def set_admin_bareme_pension
      @assure = Enrolement::AssureTpe.find(params[:id])
    end
end
