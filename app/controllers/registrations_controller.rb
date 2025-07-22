class RegistrationsController < Devise::RegistrationsController
  def new
    if user_signed_in?
      redirect_to root_path
    else
      @user = User.new
      current_uri = request.env['PATH_INFO']
      puts current_uri

      if current_uri == "/users/sign_up"
        render :new_allocataire
      elsif current_uri == "/users/allocataire-signup.user"
        render :new
      else
        build_resource
        yield resource if block_given?
        render :employer
      end
    end
    #super
    # Add logic here to detect Role and display different forms
  end

  def create
    current_uri = request.env['PATH_INFO']
    if current_uri == "/users/sign_up"
      super
    else
      resource = build_resource(sign_up_params)
      resource.type_profil = :employeur
      if resource.employeur?
        resource.numero_salarie="none"
        #resource.prenom = resource.nom
      end

      resource.save!
      yield resource if block_given?
      if resource.persisted?

        #create_immatriculation

        if resource.active_for_authentication?
          set_flash_message! :notice, :signed_up
          sign_up(resource_name, resource)
          respond_with resource, location: after_sign_up_path_for(resource)
        else
          set_flash_message! :notice, :"signed_up_but_#{resource.inactive_message}"
          expire_data_after_sign_in!
          redirect_to(root_path, notice: 'Merci pour votre inscription. Vous allez recevoiu Un mail de validation')
        end
      else
        clean_up_passwords resource
        set_minimum_password_length
        flash[:error] = @user.errors.full_messages

        render :employer
      end
    end
  end

  def update
    super
  end

  def new_allocataire
    @user = User.new
  end

  def create_allocataire
    resource = build_resource(sign_up_params)
    resource.type_profil = :allocataire
    resource.save
    yield resource if block_given?
    if resource.persisted?

      #create_immatriculation

      if resource.active_for_authentication?
        set_flash_message! :notice, :signed_up
        sign_up(resource_name, resource)
        respond_with resource, location: after_sign_up_path_for(resource)
      else
        set_flash_message! :notice, :"signed_up_but_#{resource.inactive_message}"
        expire_data_after_sign_in!
        redirect_to(root_path, notice: 'Merci pour votre inscription. Vous allez recevoiu Un mail de validation')
      end
    else
      clean_up_passwords resource
      set_minimum_password_length
      flash[:error] = @user.errors.full_messages

      render :new_allocataire
    end
  end

  private

  def after_sign_up_path_for(resource)
    '/users/sign_in'
  end

  def create_immatriculation
    immatriculation = Immatriculation.new
    immatriculation.ninea = resource.ninea
    immatriculation.raison_sociale = resource.nom
    immatriculation.type_immatriculation = :bvoln
    immatriculation.etat = :creation
    immatriculation.user = resource
    immatriculation.save!(:validate => false)
  end

  def creation_allocataire
    resource = build_resource(sign_up_params)

    allocataire = Allocataire.new
    allocataire.numero_allocataire = resource.numero_salarie
    allocataire.prenom = resource.prenom
    allocataire.nom = resource.nom
    allocataire.sexe = resource.sexe
    allocataire.telephone = resource.telephone
    allocataire.etat = :en_attente
    allocataire.save!(:validate => false)
  end

  def allocataire_params
    params.require(:user).permit(:numero_salarie, :prenom, :nom, :sexe, :telephone, :email, :password,
                                 :type_profil, :password_confirmation, :date_naissance, :lieu_naissance, :nin)
  end
end

