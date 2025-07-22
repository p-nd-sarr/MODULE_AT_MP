class Employer::EffectifsController < Employer::ApplicationController
  before_action :peut_acceder!

  def index

    @total_effectif = current_user.salarie_immatriculations
    @q = @total_effectif.ransack(params[:q])
    @effectifs = @q.result.order('prenom asc').page(params[:page]).per(100)
    @effectifs_actif = @total_effectif.actif
    @effectifs_retrait = @total_effectif.retrait

  end

  def new
    @salarie = SalarieImmatriculation.new
  end

  def create
    @salarie = SalarieImmatriculation.new(salarie_immatriculation_params)

    @salarie.user = current_user

    if @salarie.save
      redirect_to [:employer, 'effectifs'], notice: 'Le salarié a est ajouté.'
    else
      flash[:error] = @salarie.errors.full_messages
      render :new
    end
  end


  def destroy

    @salarie_immatriculation = SalarieImmatriculation.find(params[:id])

    if @salarie_immatriculation.update_attribute(:etat, :retrait)
      redirect_to [:employer, 'effectifs'], notice: 'Le salarié est retiré.'
    else
      render :show
    end

  end

  def import
    user_id = current_user.id

    puts user_id
    if params[:file].nil?
      redirect_to '/employer/effectifs', notice: "Fichier introuvable"
    else
      SalarieImmatriculation.my_import(params[:file], user_id)

      redirect_to '/employer/effectifs', notice: "Fichier salaire importé avec succés"
    end

  end

  private

  def salarie_immatriculation_params
    params.require(:salarie_immatriculation).permit(:nom, :prenom, :date_naissance, :type_piece, :numero_piece)
  end

  def peut_acceder!
    @immatriculation = current_user.immatriculation
    if @immatriculation == nil or @immatriculation.statut_demande != nil
      flash[:info] = "Immatriculation pas encore valide. Veillez faire la demande!"
      render '/employer/immatriculations/index'
    end
  end
end
