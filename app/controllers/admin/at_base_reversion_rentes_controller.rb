class Admin::AtBaseReversionRentesController < Admin::ApplicationController
    before_action :set_arret_travail
    before_action :set_arret_travail
    def index
        @at_base_reversion_rente= AtBaseReversionRente.all
     end
 
     def new
        @at_base_reversion_rente= AtBaseReversionRente.new 
     end


     def create
        @at_base_reversion_rente= AtBaseReversionRente.new(at_base_reversion_at_params)
        participant = Psrm::Participant.find_by(matric: @at_base_reversion_rente.numero_affiliation)
        @at_base_reversion_rente.enfants_id=params[:enfants_id]
        @at_base_reversion_rente.conjoints_id=params[:conjoints_id]
        @at_base_reversion_rente.ascendants_pere_id = params[:ascendants_pere_id]
        @at_base_reversion_rente.ascendants_mere_id = params[:ascendants_mere_id]

        if @at_base_reversion_rente.save
            create_reversion_veuve( @at_base_reversion_rente.conjoints_id)
            create_reversion_orphelin(@at_base_reversion_rente.enfants_id)
            create_reversion_ascendant_pere( @at_base_reversion_rente.ascendants_pere_id)
            create_reversion_ascendant_mere(@at_base_reversion_rente.ascendants_mere_id)
          redirect_to [:admin,@demande_arret_travail], notice: 'La demande de reversion est créée.'
        else
          render :new 
        end
      end
    

 
     def show
    #show
  end
 
  def edit
    #edit
  end

 

private

    def create_reversion_orphelin(enfants)

      unless enfants.nil?
        enfants.each do |enfant|
          demandeur =AtDossierReversionRente.new
          enf = Enfant.find(enfant)
          demandeur.enfant_id=enfant
          demandeur.conjoint_id=nil
          demandeur.nom = enf.nom
          demandeur.prenom = enf.prenom
          demandeur.date_naissance = enf.date_naissance
          demandeur.numero_affiliation = @at_base_reversion_rente.numero_affiliation
          #puts "ID", @at_base_reversion_rente.id
          demandeur.at_base_reversion_rente_id = @at_base_reversion_rente.id
          demandeur.etat = :creation
          demandeur.type_ayant_droit = :orphelin
         # demandeur.ajoute_par = current_user
         # demandeur.ajouter_le = DateTime.now
          demandeur.save!
        end
      end
  
    end
  
    def create_reversion_veuve(conjoints)
      unless conjoints.nil?
        conjoints.each do |conjoint|
          demandeur = AtDossierReversionRente.new
          conj = Conjoint.find(conjoint)
          demandeur.enfant_id=nil
          demandeur.conjoint_id=conjoint
          demandeur.nom = conj.nom
          demandeur.prenom = conj.prenom
          demandeur.date_naissance = conj.date_naissance
          demandeur.date_mariage = conj.date_mariage
          demandeur.numero_affiliation = @at_base_reversion_rente.numero_affiliation
         # puts "ID", @at_base_reversion_rente.id
          demandeur.etat = :creation
          demandeur.at_base_reversion_rente_id = @at_base_reversion_rente.id
          demandeur.type_ayant_droit = :veuve
         # demandeur.ajoute_par = current_user
         #   demandeur.ajouter_le = DateTime.now
          demandeur.save!
        end
      end
  
    end

    def create_reversion_ascendant_mere(ascendants)
          puts "OKKKKKKK", ascendants.inspect
          unless ascendants.nil?
         ascendants.each do |ascendant|
          demandeur = AtDossierReversionRente.new
          asc = AscendantsSalarie.find(ascendant)
          puts asc.inspect
          demandeur.enfant_id=nil
          demandeur.conjoint_id=nil
          demandeur.ascendants_salarie_id=ascendant
          demandeur.nom = asc.nom_mere
          demandeur.prenom = asc.prenom_mere
         # demandeur.date_naissance = asc.date_naissance
          demandeur.numero_affiliation = @at_base_reversion_rente.numero_affiliation
         # puts "ID", @at_base_reversion_rente.id
          demandeur.etat = :creation
          demandeur.at_base_reversion_rente_id = @at_base_reversion_rente.id
          demandeur.type_ayant_droit = :mere
          #demandeur.ajoute_par = current_user
          #demandeur.ajouter_le = DateTime.now
          demandeur.save!
        end
      end
  
    end

    def create_reversion_ascendant_pere(ascendants)
      puts "IDDDDDD", ascendants.inspect
      unless ascendants.nil?
         ascendants.each do |ascendant|
          demandeur = AtDossierReversionRente.new
          asc = AscendantsSalarie.find(ascendant)
          demandeur.enfant_id=nil
          demandeur.conjoint_id=nil
          demandeur.ascendants_salarie_id=ascendant
          demandeur.nom = asc.nom_pere
          demandeur.prenom = asc.prenom_pere
         # demandeur.date_naissance = asc.date_naissance
          demandeur.numero_affiliation = @at_base_reversion_rente.numero_affiliation
          demandeur.etat = :creation
          demandeur.at_base_reversion_rente_id = @at_base_reversion_rente.id
          demandeur.etat = :creation
          demandeur.type_ayant_droit = :pere
          #demandeur.ajoute_par = current_user
          #demandeur.ajouter_le = DateTime.now
          demandeur.save!
        end
      end
  
    end

     def set_at_base_reversion_rente
        @at_base_reversion_rente= AtBaseReversionRente.find(params[:id]|| params[:at_base_reversion_rente])
     end

     def set_arret_travail
      @demande_arret_travail= ArretTravail.find(params[:id]|| params[:arret_travail_id])
   end

     def at_base_reversion_at_params
      params.require(:at_base_reversion_rente).permit(:numero_affiliation, :date_deces, :enfants_id, :conjoints_id, :ascendats_pere_id, :ascendats_mere_id, :arret_travail_id)
    end
end
 