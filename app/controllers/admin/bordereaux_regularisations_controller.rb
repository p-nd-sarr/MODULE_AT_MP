class Admin::BordereauxRegularisationsController < Admin::ApplicationController
    def index
      @regularisation_pensions = RegularisationPension.all.where(etat: :regularise) 
    end
  
    
  end
