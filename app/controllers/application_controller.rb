class ApplicationController < ActionController::Base
  before_action :authenticate_user!, except: [:public_pdf]
  before_action :configure_permitted_parameters, if: :devise_controller?
  before_action :set_tracking!
  before_action :set_current_user

  def set_current_user
    User.current = current_user
  end

  helper_method :format_cfa, :format_cfa_not_rounded, :format_cfa_net, :set_period_for_allocation_f, :format_entier

  # @return [User]
  # def current_user
  #   super
  # end

  def format_entier(value)
    return '' if value.nil?
    value = value.to_s(:delimited, delimiter: " ")
    value.chomp!(',0')
    value
  end

  def format_cfa(value, unite = true)
    return '' if value.nil?
    value = value.to_f
    str = value.to_s(:rounded, precision: 0).gsub(',', '.').to_f
    str = str.to_s(:delimited,
                   delimiter: ' ',
                   separator: ',')
    str.chomp!(',0')
    unite ? "#{str} F.CFA" : str
  end

  def format_cfa_not_rounded(value, unite = true)
    return '' if value.nil?
    value = (value.to_f).ceil
    unite ? "#{value} F.CFA" : str
  end

  def format_cfa_net(value, unite = true)
    return '' if value.nil?
    value = (value.to_f)
    unite ? "#{value} F.CFA" : str
  end

  def get_last_month_of_trimestre(trimestre)
    3 * trimestre.to_i
  end

  def set_period_for_allocation_f(trimestre, annee)
    month = get_last_month_of_trimestre(trimestre)
    return nil if annee.nil? or month.nil?
    date = Date.new(annee, month, 1)
    date = date.change(day: date.end_of_month.day)
    date
  end

  protected

  def configure_permitted_parameters
    registration_params = [:email, :password, :password_confirmation, :type_profil, :prenom, :nom, :telephone,
                           :numero_salarie, :num_immatriculation, :num_css, :num_ipres, :ninea, :sexe,
                           :type_employeur, :raison_sociale, :fonction, :numero_unique,
                           :date_naissance, :lieu_naissance, :nin, :numero_matricule_solde, :autres_informations_utiles, :telephone_bureau, 
                           :cni_file, :image_profile, :raison_sociale_employeur_actuel, :certificat_travail_actuel, :telephone_employeur_actuel, :raison_sociale_employeur_precedent, :certificat_travail_precedent, :telephone_employeur_precedent ]

    devise_parameter_sanitizer.permit(:update, keys: registration_params << :current_password)
    devise_parameter_sanitizer.permit(:create, keys: registration_params)
    devise_parameter_sanitizer.permit(:sign_up, keys: registration_params)
  end

  def only_salarie!
    unless current_user.salarie?
      flash[:error] = 'Seul un salarié peut accéder à cette ressource'
      redirect_back(fallback_location: root_path)
    end
  end

  def only_caissier!
    unless current_user.caissier_ipres?
      flash[:error] = 'Seul un caissier peut accéder à cette ressource'
      redirect_back(fallback_location: root_path)
    end
  end

  def only_admin!
    unless current_user.admin?
      flash[:error] = 'Seul les admins peuvent accéder à cette ressource'
      redirect_back(fallback_location: root_path)
    end
  end

  def only_employer!
    unless current_user.employeur?
      flash[:error] = 'Seul les admins peuvent accéder à cette ressource'
      redirect_back(fallback_location: root_path)
    end
  end

  def only_acces_employer!
    unless current_user.employeur? or current_user.gestionnaire_compte_salarie?
      flash[:error] = 'Seul les admins peuvent accéder à cette ressource'
      redirect_back(fallback_location: root_path)
    end
  end

  def only_allocataire!
    unless current_user.allocataire?
      flash[:error] = 'Seul un allocataire peut accéder à cette ressource'
      redirect_back(fallback_location: root_path)
    end
  end

  def only_user_back_office!
    unless current_user.user_back_office?
      flash[:error] = 'Seul les utilisateurs du back office peuvent accéder à cette ressource'
      redirect_back(fallback_location: root_path)
    end
  end

  def only_can_allocataire!
    unless current_user.can_allocataire?
      flash[:error] = 'Seul les gestionnaires et le chef de service peuvent accéder à cette ressource'
      redirect_back(fallback_location: root_path)
    end
  end

  private

  # Overwriting the sign_out redirect path method
  def after_sign_out_path_for(resource_or_scope)
    new_user_session_path
  end

  def set_tracking!
    return if Rails.env == 'development'
    return unless user_signed_in?

    if request.env['HTTP_X_FORWARDED_FOR']
      ip = request.env['HTTP_X_FORWARDED_FOR'].gsub(/\s+/, '').split(',').first
    else
      ip = request.env['HTTP_CLIENT_IP'] || request.remote_ip
    end
    Tracking.create(user: current_user,
                    type_requete: request.request_method,
                    path: request.fullpath,
                    path_source: request.referer,
                    ip: ip, # request.env['HTTP_CLIENT_IP'] || request.remote_ip,
                    controller: controller_name,
                    action: action_name
    )
  end
end
