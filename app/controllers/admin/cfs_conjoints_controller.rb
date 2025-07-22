class Admin::CfsConjointsController < ApplicationController

  def index
    numero_immatriculation = params[:numero_immatriculation]

    # if params[:format] != 'json'
      @conjoints = CfsConjoint.where(numero_immatriculation: numero_immatriculation).order('nom DESC')
      # @cfs_onjoints = CfsConjoint.all.order('nom DESC')

    # end
  end



end
