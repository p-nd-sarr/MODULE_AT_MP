require 'bcrypt'

module Api
  # Contrôleur de base pour tous les points de terminaison de l'API.
  # Il gère l'authentification, la gestion des erreurs et la configuration commune.
  class ApplicationController < ActionController::API
    include ActionController::HttpAuthentication::Token::ControllerMethods

    # --- CONSTANTES ---
    # Le hash BCrypt du jeton d'authentification de l'API.
    # La valeur est chargée depuis les variables d'environnement pour des raisons de sécurité.
    # Assurez-vous que la variable d'environnement API_AUTH_TOKEN_HASH est définie.
    API_TOKEN_HASH = ENV['API_AUTH_TOKEN_HASH']

    # --- FILTRES ---

    # Authentification par jeton pour toutes les actions de l'API.
    before_action :authenticate_with_token

    # Désactive l'authentification Devise (basée sur les sessions) pour l'API.
    skip_before_action :authenticate_user!, raise: false

    # Désactive la protection CSRF, non nécessaire pour une API stateless.
    #skip_before_action :verify_authenticity_token

    # --- GESTION DES ERREURS ---

    # Gère les erreurs lorsqu'un enregistrement n'est pas trouvé (ex: Model.find(non_existent_id)).
    # Renvoie une réponse 404 Not Found.
    rescue_from ActiveRecord::RecordNotFound, with: :render_not_found_response

    # Gère les erreurs lorsque des paramètres requis sont manquants (ex: params.require(:user)).
    # Renvoie une réponse 400 Bad Request.
    rescue_from ActionController::ParameterMissing, with: :render_parameter_missing_response

    private

    # Authentifie la requête en utilisant un jeton d'authentification HTTP Bearer.
    # Le jeton fourni par le client est comparé au hash BCrypt stocké.
    def authenticate_with_token
      authenticate_or_request_with_http_token do |token, _options|
        # Empêche l'authentification si le hash du token n'est pas configuré dans l'environnement.
        return false if API_TOKEN_HASH.blank?

        begin
          bcrypt_hash = BCrypt::Password.new(API_TOKEN_HASH)
          # La méthode `==` de BCrypt::Password est conçue pour être sécurisée contre les attaques temporelles.
          bcrypt_hash == token
        rescue BCrypt::Errors::InvalidHash
          # Si le hash stocké est invalide, l'authentification échoue systématiquement.
          # Logguer cette erreur peut être utile pour le débogage.
          Rails.logger.error "BCrypt::Errors::InvalidHash: Le hash du jeton API (API_AUTH_TOKEN_HASH) est invalide."
          false
        end
      end
    end

    def render_not_found_response(exception)
      render json: { error: "Ressource non trouvée", details: exception.message }, status: :not_found
    end

    def render_parameter_missing_response(exception)
      render json: { error: "Paramètre manquant", details: "Le paramètre requis '#{exception.param}' est manquant dans la requête." }, status: :bad_request
    end
  end
end