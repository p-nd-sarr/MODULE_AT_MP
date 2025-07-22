class Employer::RepresentantLegalsController < Employer::ApplicationController

  def index
    @representant = current_user.representant_legal
  end

  def new

  end

  def show
    #show
  end

  def create

    puts " create representant societe private"

    @representant = RepresentantLegal.new(representant_params)

    @representant.user = current_user

    if @representant.save

      # save immatriculation
      save_immatriculation()
      redirect_to [:employer,'immatriculations'] , notice: "representant créée avec succès."
    else
      puts @representant.errors.full_messages
      flash[:error] = @representant.errors.full_messages
      render [:employer,  'immatriculations']
    end

  end

  def edit
    #edit
  end

  def update
    @representant = RepresentantLegal.find(params[:id])
    if @representant.update(representant_params)
      immatriculation = current_user.immatriculation

      immatriculation.representant_valide!(false)
      redirect_to [:employer,'immatriculations'], notice: "representant was successfully updated."
    else
      puts @representant.errors.full_messages
      flash[:error] = @representant.errors.full_messages
      render [:employer,'immatriculations']
    end
  end

  private

  def save_immatriculation()

    case @representant.type_employeur
    when "MAIN"
      puts "---> create immatriculation"
      type_employeur = Admin::TypeEmployeur.find_by_code(@representant.type_employeur)
      puts " -----> type_employeur : #{type_employeur.code}"
      immatriculation = Immatriculation.new
      immatriculation.admin_type_employeur = type_employeur
      immatriculation.raison_sociale = current_user.nom
      immatriculation.ninea = current_user.ninea
      immatriculation.user = current_user

      immatriculation.save
    when "AUTRE"

    end

  end
  def representant_params
    params.require(:representant_legal).permit(:last_name, :first_name, :birthdate, :nationality, :place_of_birth, :issued_date,
                                            :expiry_date, :type_of_identity, :identity_number, :mobile_number, :email , :region, :departement, :ville, :commune, :quartier, :address, :type_employeur )
  end


end