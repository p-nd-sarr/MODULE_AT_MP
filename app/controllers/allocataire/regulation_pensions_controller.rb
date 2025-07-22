class Allocataire::RegulationPensionsController < ApplicationController

    def index
        @regulation_pensions = RegulationPension.all
    end


    def show
    #show
  end


    def new
        @regulation_pension = RegulationPension.new
        @regulation_pension.numero_allocataire = current_user.numero_salarie
        @regulation_pension.prenom = current_user.prenom
        @regulation_pension.nom = current_user.nom
      
    end
    def create
        @regulation_pension = RegulationPension.new(regulation_pension_params)
        @regulation_pension.user = current_user
        @regulation_pension.ajoute_par = current_user
        @regulation_pension.etat = :soumis
    
        if @regulation_pension.save
            redirect_to allocataire_regulation_pensions_url, notice: 'Demande encours de traitement.'
        else
          render :new
        end
    end

    def soumission_form; end

    def soumettre
      if @regulation_pension.update(soumission_regulation_pension_params.merge(etat: :soumis, date_soumission: DateTime.now))
        redirect_to [:allocataire, @regulation_pension], notice: 'La demande de régulation de pension est soumise.'
      else
        render :soumission_form
      end
    end
    
    private
    
    def set_regulation_pension
      @regulation_pension = RegulationPension.find(params[:id] || params[:regulation_pension_id])
    end 

    def regulation_pension_params
        params.require(:regulation_pension).permit(:numero_allocataire, :prenom, :nom, :motif_regulation_pension, :attachment)
    end  

    def soumission_regulation_pension_params
      params.require(:regulation_pension ).permit(:condition_1, :condition_2, :condition_3)
    end

    
end
