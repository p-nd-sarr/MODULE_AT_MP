class Employer::SalarieImmatriculationsController < Employer::ApplicationController

  def index
    @salaries = current_user.document_immatriculations
  end

  def new

  end

  def show
    redirect_to 'employer/immatriculations', notice: ""
  end

  def create

    puts " create salarié societe private"

    @salarie_immatriculation = SalarieImmatriculation.new(salarie_immatriculation_params)

    @salarie_immatriculation.user = current_user
    @salarie_immatriculation.nin_cedeao = @salarie_immatriculation.numero_piece
    @salarie_immatriculation.nin = @salarie_immatriculation.numero_piece
    if @salarie_immatriculation.save
      redirect_to [:employer, 'immatriculations'], notice: "salarié ajout avec succès"
    else
      puts @salarie_immatriculation.errors.full_messages
      flash[:error] = @salarie_immatriculation.errors.full_messages
      redirect_to [:employer, 'immatriculations'], notice: "Erreur sur le traitement"
    end

  end

  def edit
    #edit
  end

  def update
    @salarie_immatriculation = SalarieImmatriculation.find(params[:id])
    if @salarie_immatriculation.update(salarie_immatriculation_params)

      redirect_to [:employer, 'immatriculations'], notice: "Salarié modifié avec succés."
    else
      puts @salarie_immatriculation.errors.full_messages
      flash[:error] = @salarie_immatriculation.errors.full_messages
      render 'employer/immatriculations'
    end
  end


  def import
    user_id = current_user.id

    puts user_id
    if params[:file].nil?
      redirect_to '/employer/immatriculations', notice: "Fichier introuvable"
    else
      SalarieImmatriculation.my_import(params[:file], user_id)
      redirect_to '/employer/immatriculations', notice: "Fichier salaire importé avec succés"
    end

  end


  private

  def salarie_immatriculation_params
    params.require(:salarie_immatriculation).permit(:nom, :prenom, :matricule, :sexe, :etat_civil, :date_naissance, :numero_registre_naiss, :prenom_pere, :nom_pere, :prenom_mere,
                                                    :type_piece, :numero_piece, :nin, :nin_cedeao, :date_delivrance, :date_expiration, :employer_precedent, :adresse, :boite_postal,
                                                    :type_mouvement, :date_debut_contrat, :date_fin_contrat, :emploi, :salaire_contractuel, :categorie,
                                                    :nationalite, :pays_delivrance, :ville_naissance, :pays, :nature_contrat, :profession, :convention_applicable, :region, :departement,
                                                    :commune, :quartier, :pays_naissance, :nom_mere, :est_cadre, :arondissement, :temps_travail)
  end


end