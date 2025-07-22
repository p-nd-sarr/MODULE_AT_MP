require 'sidekiq/web'

Rails.application.routes.draw do

  namespace :api do
    resources :arret_travail_geds, defaults: { format: :json }
    resources :dossier_prestation_geds, defaults: { format: :json }
  end
  namespace :admin do
    resources :arret_travail_geds do
      get 'migrer_prod'
    end
  end 

  namespace :admin do
    resources :dossier_prestation_geds do
      get 'migrer_prod'
    end
  end

  namespace :admin do
    resources :icm_modifier_info_personelles
  end
  namespace :admin do
    resources :gesadms
  end
  namespace :admin do
    resources :etablissements
  end
  namespace :admin do
    resources :reg_beneficiaries
  end
  namespace :admin do
    resources :association_allocataires
    resources :cips do
      get :show_recipisse
    end
    scope '/cips' do
      get '/get_one/:id' => 'cips#show_cip_info', as: :show_cip_info
    end
  end
  namespace :admin do

    resources :salaire_annuels
  end
  namespace :admin do
    resources :rentes

    resources :banque_agences

  end
  namespace :admin do
    resources :jour_ouvrable_annuels
  end
  namespace :admin do
    resources :banques
  end
  # For details on the DSL available within this file, see http://guides.rubyonrails.org/routing.html
  #

  devise_scope :user do
    get "users/employer-signup" => "registrations#new"
    post "users/employer-signup" => "registrations#create"
    get "users/allocataire-signup" => "registrations#new_allocataire"
    post "users/allocataire-signup" => "registrations#create_allocataire"
  end

  devise_for :users #, skip: [:registrations]

  get 'edit_password' => 'home#edit_password', as: :edit_password
  post 'password_update' => 'home#password_update', as: :password_update

  root to: 'home#index'
  resources :documents

  namespace :salarie do
    root to: 'home#index'
    get 'information' => 'home#show'

    scope '/carrieres' do
      get '/' => 'carrieres#index', as: :carrieres
    end

    resources :conjoints
    resources :enfants

    resources :dossier_prestations do
      get :valider_etat_civil_demandeur
      get :valider_enfants
      get :valider_carriere
      get :valider_documents
      post :create_document
      get :suivi_droits
      get :historique_dossier


      get '/update_document_form/:document_dossier_prestation_id' => 'dossier_prestations#update_document_form', as: :update_document_form
      patch '/update_document/:document_dossier_prestation_id' => 'dossier_prestations#update_document', as: :update_document

      delete '/delete_document/:document_dossier_prestation_id' => 'dossier_prestations#destroy_document', as: :destroy_document

      get 'recipisse_dossier_prestation' => 'dossier_prestations#recipisse_dossier', as: :recipisse_dossier

      get :soumission_form
      patch :soumettre

      get :enregistrer

      resources :grossesses do
        get :interruption_form
      end

      resources :allocation_prenatales do
        get :soumission_form
        patch :soumettre
      end

      resources :allocation_postnatales do
        get :soumission_form
        patch :soumettre


      end

      resources :allocation_familiales do
        get :valider_documents
        post :create_document
        get :soumission_form
        patch :soumettre
      end
    end

    resources :dossier_cnavs do
      patch :soumettre

    end

    resources :dossier_maternites do
      get :valider_etat_civil_demandeur
      get :valider_carriere
      get :valider_documents
      post :create_document
      get :historique_dossier


      get '/update_document_form/:document_dossier_maternite_id' => 'dossier_maternites#update_document_form', as: :update_document_form
      patch '/update_document/:document_dossier_maternite_id' => 'dossier_maternites#update_document', as: :update_document

      delete '/delete_document/:document_dossier_maternite_id' => 'dossier_maternites#destroy_document', as: :destroy_document

      get 'recipisse_dossier_maternites' => 'dossier_maternites#recipisse_dossier', as: :recipisse_dossier

      #get :soumission_form
      patch :soumettre

      resources :indemnite_conges_maternites do
        get :soumission_form
        patch :soumettre
      end
    end

    resources :liquidation_retraites do
      get :valider_etat_civil_demandeur
      get :valider_epouses
      get :valider_enfants
      get :valider_carriere
      get :valider_documents
      get 'facture_liquidation/facture_liquidation_retraite_id' => 'liquidation_retraites#show_facture', as: :show_facture
      post :create_document
      delete '/delete_document/:document_liquidation_retraites_id' => 'liquidation_retraites#destroy_document', as: :destroy_document

      get :soumettre
      #patch :soumettre
    end
  end

  scope '/agences' do
    get '/single_agence/:code_agence' => 'admin/agences#single_agence', as: :single_agence
  end

  namespace :admin do
    root to: 'home#index'

    authenticate :user, ->(user) { user.admin? or user.super_admin? } do
      mount Sidekiq::Web => '/sidekiq'
    end

    get 'viderrrrrrr/:y/:m/:d' => 'home#viderrrrrrr'
    get 'prestation_retraite/index'
    get 'tableau_bord/index'

    resources :demande_carte_allocataires do
      get :imprimer
    end

    resources :css_transfert_employeurs do
      get 'change_statut/:statut', to: 'css_transfert_employeurs#change_statut', as: :change_transfert_statut
      patch 'change_transfert_statut_with_motif/:statut', to: 'css_transfert_employeurs#change_statut', as: :change_transfert_statut_with_motif
    end

    resources :css_transfert_allocataires do
      get 'change_statut/:statut', to: 'css_transfert_allocataires#change_statut', as: :change_transfert_allocataire_statut
      patch 'change_transfert_statut_with_motif/:statut', to: 'css_transfert_allocataires#change_statut', as: :change_transfert_allocataire_statut_with_motif
    end

    resources :dossier_audits do
      get :activities
      post :create_activity
      get :generate_audit_report
      get 'get_activity_ready/:activity_id', to: 'dossier_audits#get_activity_ready', as: :get_activity_ready
      post 'create_recommandation/:activity_id', to: 'dossier_audits#create_recommandation', as: :create_recommandation
      patch 'update_recommandation/:dossier_audit_id/:activity_id/:activity_rec_id', to: 'dossier_audits#update_recommandation', as: :update_recommandation
      get 'activity_details/:activity_id', to: 'dossier_audits#activity_details', as: :activity_details
      patch 'update_activity/:activity_id', to: 'dossier_audits#update_activity', as: :update_activity
      delete 'delete_activity/:activity_id', to: 'dossier_audits#delete_activity', as: :delete_activity
      delete 'delete_recommandation/:activity_rec_id', to: 'dossier_audits#delete_recommandation', as: :delete_recommandation
      get 'change_statut/:statut', to: 'dossier_audits#change_statut', as: :change_statut
      patch 'change_statut_with_motif/:statut', to: 'dossier_audits#change_statut', as: :change_statut_with_motif
      get 'change_activity_statut/:activity_id/:statut', to: 'dossier_audits#change_activity_statut', as: :change_activity_statut
      patch 'change_activity_statut_with_motif/:activity_id/:statut', to: 'dossier_audits#change_activity_statut', as: :change_activity_statut_with_motif
    end

    scope '/dossier_audits' do
      get '/validation/dossier_audits_recommandations_en_attente/' => 'dossier_audits#recommandations_en_attente', as: :dossier_audits_recommandations_en_attente
      get '/validation/dossier_audits_en_attente_validation/' => 'dossier_audits#en_attente_validation', as: :dossier_audits_en_attente_validation
      get '/validation/dossier_audits_activites_en_attente_validation/' => 'dossier_audits#activites_en_attente_validation', as: :dossier_audits_activites_en_attente_validation
      get '/affecter_dossier_audit/:id/:agent_id' => 'dossier_audits#affecter_dossier', as: :affecter_dossier_audit
      get '/annuler_affectation_dossier_audit/:id/:agent_id' => 'dossier_audits#annuler_affectation_dossier', as: :annuler_affectation_dossier_audit
    end

    resources :type_dossier_juridiques
    resources :dossier_juridiques do
      get :historique
      get :soumettre
      get :cloturer
      patch :rejeter
    end
    resources :avocats_huissiers
    resources :dossier_juridique_honoraires
    resources :dossier_juridique_actes

    scope '/dossier_juridiques' do
      get '/affecter_dossier/:id/:agent_id' => 'dossier_juridiques#affecter_dossier', as: :affecter_dossier
      get '/annuler_affectation_dossier/:id/:agent_id' => 'dossier_juridiques#annuler_affectation_dossier', as: :annuler_affectation_dossier
    end

    resources :ascendants_salaries

    scope '/ascendants_salaries' do
      get '/listascendant/:numero_affiliation' => 'ascendants_salaries#listascendant', as: :listascendant
    end

    resources :compta_transactions, only: [:index]

    resources :etats_familles_salaries do
      get 'generate_etat/' => 'etats_familles_salaries#generate_etat', as: :generate_etat
    end

    resources :users, controller: :utilisateurs do
      get :activer
      get :desactiver
      get 'lock'
      get 'unlock', as: :unlock_user
      delete 'destroy'
    end

    scope '/carrieres' do
      get '/' => 'carrieres#index', as: :carrieres
      get '/employeur/:employeur_id' => 'carrieres#employeur', as: :carriere_employeur
    end

    scope '/salaries' do
      get '/' => 'salaries#index', as: :salaries
      get '/:matricule' => 'salaries#show', as: :salarie
      get '/edit/:matricule' => 'salaries#edit', as: :salarie_edit
      get '/cni/:cni' => 'salaries#show_cni', as: :salarie_cni
      patch '/update/:matricule' => 'salaries#update', as: :salarie_update
    end

    # scope '/employeurs' do
    #   get '/' => 'employeurs#index', as: :employeurs
    #   get '/single_employeur/:numero_employeur' => 'employeurs#single_employeur', as: :single_employeur
    #   get '/all_employeur' => 'employeurs#all_employeur', as: :all_employeur
    #   get '/:ninea' => 'employeurs#show', as: :employeur
    #   get '/declarations/:ninea' => 'employeurs#declarations', as: :employeur_declarations
    #   get '/immatriculation/:ninea' => 'employeurs#immatriculation', as: :employeur_immatriculation
    # end
    #
    scope '/employeurs' do
      get '/single_employeur/:numero_employeur' => 'employeurs#single_employeur', as: :single_employeur
    end

    resources :employeurs do
      get 'declaration_manquante/:dsm_id/charger' => 'employeurs#declaration_manquante_charger', as: :declaration_manquante_charger
      post 'declaration_manquante/:dsm_id/charger' => 'employeurs#declaration_manquante_charger_create', as: :declaration_manquante_charger_create
      get 'declaration_manquante/:dsm_id/chargement/:id' => 'employeurs#declaration_manquante_charger_show', as: :declaration_manquante_charger_show
      get 'declaration_manquante/:dsm_id/chargement/:id/valider' => 'employeurs#declaration_manquante_charger_valider', as: :declaration_manquante_charger_valider
      post 'declaration_manquante/:dsm_id/chargement/:id/rejeter' => 'employeurs#declaration_manquante_charger_rejeter', as: :declaration_manquante_charger_rejeter
      get :chargements_edi, on: :collection
      get :declarations_manquantes, on: :collection
      get :declarations_manquantes_new, on: :collection
      post :declarations_manquantes_create, on: :collection
    end

    resources :bordereau_collectifs

    scope '/allocataires' do
      get '/all_revisions' => 'allocataires#all_revisions', as: :all_revisions
    end

    resources :allocataires do
      get 'allocataires/import' => 'allocataires#my_import'
      collection { post :import }

      #get 'allocataires/update_affiliation' => 'allocataires#update_affiliation'
      #collection { post :update_affiliation }

      #get '/:numero_allocataire' => 'allocataires#show', as: :allocataire
      get :historiques_suivi, on: :collection
      get :demandes_en_attente, on: :collection
      get :demandes_a_activer, on: :collection
      get :suspension_soumis, on: :collection
      get :suspendus, on: :collection
      get :demandes_modifier_adresses_affectees, on: :collection
      get :demandes_grappes_familiales_affectees, on: :collection
      get :demandes_modifier_adresses, on: :collection
      get :demandes_modifier_mode_paiements, on: :collection
      get :demandes_regularisation_pensions, on: :collection
      get :demandes_grappes_familiales, on: :collection
      get :toutes_les_demandes, on: :collection
      get :activer
      get :valider
      patch :rejeter
      get :suspendre
      get :demande_suspension
      get :historique
      get :lever_suspension
      get :soumettre
      get :en_attente_soumission, on: :collection
      get :en_attente_affection, on: :collection
      get :en_attente_verification, on: :collection
      get :en_attente_validation, on: :collection
      get :allocataires_actifs, on: :collection
      get :allocataires_eteints, on: :collection
      get :allocataires_affilies_association, on: :collection
      get :historiques_paiements, on: :collection
      get :affiliation_association
      patch :affilier_association
      get :imprimer_carte_allocataire
      delete :rejeter_allocataire


      resources :suspension_allocataires do
        get :soumettre
        get :valider
        get :verifier
        patch :rejeter
        patch :affecter
      end

      resources :extinction_allocataires do
        get :soumettre
        get :valider
        get :verifier
        patch :rejeter
        patch :affecter
      end
      resources :base_reversions
      resources :reversion_veuves do
        get :est_eligible
        get :pas_eligible
        get :instruire
        get :soumettre
        get :valider
        get :rejeter
        get :valider_recapitulatif
        get :liquider
        patch :affecter_allocataire
        get :affecter_allocataire_all, on: :collection
        get :en_attente_affectation_allocataire, on: :collection

        get 'lettre_notification' => 'reversion_veuves#lettre_notification', as: :lettre_notification

        get :toutes_demandes, on: :collection
        get :mes_demandes, on: :collection

        patch :retourner_process


      end
      resources :revision_pensions do
        patch :affecter_allocataire
        patch :affecter_salarie
        patch :soumettre
        patch :retourner_dossier

        #get :soumettre
        get :instruire
        get :soumettre_carriere
        get :valider_cotisation
        get :soumettre_recapitulatif
        get :valider_liquidation
        get :valider
        get :rejeter
        get :valider_revision
        get :valider_directeur

        post :ajouter_carriere
        patch :update_carriere
        get :valider_ligne_carriere
        get :delete_ligne_carriere
        get :lettre_notification

      end
      resources :regularisation_pensions do
        get :valider_etat_civil_demandeur
        get :valider_documents
        get :soumettre
        get :instruire
        patch :retourner_process
        patch :affectation
        patch :affecter_allocataire
        get :valider_recapitulatif
        get :liquidation_valide
        get :recap_valide
        get :valider
        get :dossier_valide
        get :dossier_rejete
        get :regulariser
        patch :rejeter
        get :prendre_en_charge
        get :lettre_notification
        
      end
      resources :update_grappe_familiales do
        patch :affectation
        get :valider
        get :valider_enfant
        get :valider_conjoint
        patch :rejeter
      end
      resources :modifier_mode_paiements do
        patch :affectation
        get :valider_etat_civil_demandeur
        get :valider_documents
        get :soumettre
        patch :retourner_process
        patch :affecter_allocataire
        get :valider_modification
        get :soumettre_modification
        get :valider
        get :dossier_valide
        get :dossier_rejete
        patch :rejeter
      end

      resources :modifier_adresses do
        patch :affectation
        get :valider_etat_civil_demandeur
        get :valider_documents
        get :soumettre
        patch :retourner_process
        patch :affecter_allocataire
        get :valider_modification
        get :soumettre_modification
        get :valider
        get :dossier_valide
        get :dossier_rejete
        patch :rejeter
        get :en_attente_soumission, on: :collection
        get :en_attente_affection, on: :collection
        get :en_attente_verification, on: :collection
        get :en_attente_validation, on: :collection
        
       
      end
      resources :pension_alimentaires do
        get :rejeter
        get :valider_par_directeur
        patch :valider_chef_service
      end
      resources :avis_tiers do
        get :rejeter
        get :valider_par_directeur
        patch :valider_chef_service
      end
      resources :pret_allocataire_lignes do
        get :valider
        get :rejeter
      end
      resources :paiement_allocataires do
        get :retourner
      end
      get :list_grappe_familiale
      get :en_attente
      get :valider
      get :rejeter
      get :historique
      get :lever_suspension
      get :suspendre
    end

    scope '/allocataires' do

      patch '/affecter_update_grappe_familiale/:id' => 'allocataires#affecter_update_grappe_familiale', as: :affecter_update_grappe_familiale
      get '/valider_update_grappe_conjoint/:id' => 'allocataires#valider_update_grappe_conjoint', as: :valider_update_grappe_conjoint
      get '/valider_update_grappe_enfant/:id' => 'allocataires#valider_update_grappe_enfant', as: :valider_update_grappe_enfant
      patch '/rejeter_update_grappe_conjoint/:id' => 'allocataires#rejeter_update_grappe_conjoint', as: :rejeter_update_grappe_conjoint
      patch '/rejeter_update_grappe_enfant/:id' => 'allocataires#rejeter_update_grappe_enfant', as: :rejeter_update_grappe_enfant
      get '/show_update_grappe_familiale/:id' => 'allocataires#show_update_grappe_familiale', as: :show_update_grappe_familiale
      get '/suspension_allocataires_soumis' => 'allocataires#suspension_allocataires_soumis'
      get '/show_suspension_allocataire/:id' => 'allocataires#show_suspension_allocataire', as: :show_suspension_allocataire
      patch '/rejeter_suspension_allocataire/:id' => 'allocataires#rejeter_suspension_allocataire', as: :rejeter_suspension_allocataire
      get '/valider_suspension_allocataire/:id' => 'allocataires#valider_suspension_allocataire', as: :valider_suspension_allocataire

    end

    resources :bordereaux_regularisations


    resources :pension_alimentaires do
      get 'lettre_notification' => 'pension_alimentaires#lettre_notification', as: :lettre_notification
    end


    resources :avis_tiers do
      get 'lettre_notification' => 'avis_tiers#lettre_notification', as: :lettre_notification
    end

    resources :reversion_veuves do

      get :en_attente_validation, on: :collection
      get :en_attente_affectation, on: :collection
      get :en_attente_instruction, on: :collection
      get :en_attente_validation_recap, on: :collection
      get :en_attente_validation_liquidation, on: :collection
      get :en_attente_validation_dossier, on: :collection
      get :en_attente_affectation_allocataire, on: :collection

      get 'lettre_notification' => 'reversion_veuves#lettre_notification', as: :lettre_notification
      get '/affecter_dossier/:agent_id' => 'reversion_veuves#affecter_dossier', as: :affecter_dossier_reversion_veuve
      get '/annuler_affectation_dossier/:agent_id' => 'reversion_veuves#annuler_affectation_dossier', as: :annuler_affectation_dossier_reversion_veue

      get :toutes_demandes, on: :collection
      get :mes_demandes, on: :collection

    end


    resources :arret_travails do

      delete '/at_salaires/:id' => 'arret_travails#delete_salaire'
      delete '/at_incapacites/:id' => 'arret_travails#delete_incapacite'
      delete '/at_frais_engages/:id' => 'arret_travails#delete_frais_engage'
      delete '/at_code_prime_salaires/:id' => 'arret_travails#delete_prime_salaire'
      get '/at_valid_custom_page/:custom_page' => 'arret_travails#validate_onglet'
      get 'recipisse_dossier_at' => 'arret_travails#recipisse_dossier', as: :recipisse_dossier_at
      get :soumission_form
      get :soumettre
      get :soumission_chef_atmp
      get :soumission_chef_division_at
      get :soumission_directeur
      get :directeur_accepte
      get :directeur_rejete
      get :liquidation_soumis
      get :liquidation_valide
      get :validation_medecin
      get :validation
      get :acceptation_commission
      get :rejet_commission
      post :user_affectation
      get :user_affectation_aleatoire, on: :collection
      patch :decision_commission_rejet
      post :add_element_salaire
      post :update_document_cloture_info
    
      #---Cloturer dossier AT
      get :cloture_dossier_form
      patch :soumettre_demande_cloture
      get :valider_demande_cloture
      get :cloturer_dossier_at
      #---Annulation guerison AT
      get :annulation_guerison_form
      patch :soumettre_annulation_guerison
      get :valider_annulation_guerison
      get :en_attente_annulation_guerison, on: :collection
      get :en_attente_affectation_dossoer_rechute, on: :collection
      get :en_attente_liquidation_dossoer_rechute, on: :collection
      #--- Reouverture dossier AT
      get :reouverture_dossier_form
      patch :soumettre_demande_reouverture
      post :demande_reouverture_dossier
      get :soumettre_rechute
      get :soumission_rechute_mc
      get :rechute_validee_medecin
      get :rechute_validee
      get :valider_demande_reouverture
     
      get :reouvrire_dossier_at
      get :valider_documents
      get :confirmation_taux_ipp
     
      get '/liquidation_at_frais_engages/:id/:anchor_tag' => 'arret_travails#liquidation_frais_engages'
      get '/liquidation_tous_at_frais_engages' => 'arret_travails#liquidation_tous_frais_engages', as: :liquidation_tous_frais_engages

      get '/liquidation_at_decomptes/:id/:anchor_tag' => 'arret_travails#liquidation_decomptes'
      get '/liquidation_tous_at_decomptes' => 'arret_travails#liquidation_tous_decomptes', as: :liquidation_tous_at_decomptes

      get '/validation_at_decomptes/:id/:anchor_tag' => 'arret_travails#validation_decomptes'
      get '/validation_tous_at_decomptes/:anchor_tag' => 'arret_travails#validation_tous_decomptes'
      get '/validation_at_decomptes_comptable/:id/:anchor_tag' => 'arret_travails#validation_decomptes_comptable'
      get '/validation_at_decomptes_medecin/:id/:anchor_tag' => 'arret_travails#validation_decomptes_medecin'

      get '/validation_at_frais_engages/:id/:anchor_tag' => 'arret_travails#validation_frais_engages'
      get '/validation_at_frais_engages_comptable/:id/:anchor_tag' => 'arret_travails#validation_at_frais_engages_comptable'
      get '/validation_at_frais_engages_medecin/:id/:anchor_tag' => 'arret_travails#validation_at_frais_engages_medecin'
      
      get '/validation_tous_at_frais_engages/:anchor_tag' => 'arret_travails#validation_tous_frais_engages'


      get :en_creation, on: :collection
      get :en_attente_soumis_chef_agence, on: :collection
      get :en_attente_instruction, on: :collection
      get :en_attente_information, on: :collection
      get :en_attente_soumis_directeur, on: :collection
      get :en_attente_affectation_redacteur, on: :collection
      get :en_attente_avis_redacteur, on: :collection
      get :en_attente_avis_dajc, on: :collection
      get :en_attente_avis_chef_service_at, on: :collection
      
      get :en_attente_avis_dprp, on: :collection
      get :en_attente_avis_medecin, on: :collection
      get :en_attente_acceptation, on: :collection
      get :en_attente_affectation_technicien, on: :collection
      get :en_attente_soumission_liquidation, on: :collection
      #get :en_attente_validation_liquidation, on: :collection
      get :en_attente_validation_ij, on: :collection
      get :en_attente_validation_frais, on: :collection
      get :en_attente_validation_mc_ij, on: :collection
      get :en_attente_validation_mc_frais, on: :collection
      get :en_attente_validation_comptable_ij, on: :collection
      get :en_attente_validation_comptable_frais, on: :collection
      get :en_attente_commission_rejets, on: :collection
      get :en_attente_retour_commission_saisi, on: :collection
      get :en_attente_soumission_dir_at, on: :collection
      get :consolidations_soumises, on: :collection
      get :consolidations_soumises_mc, on: :collection
      get :consolidations_confirmees, on: :collection
      get :consolidations_validees, on: :collection
      get :en_attente_validation_reouverture_dossier, on: :collection
      get :en_attente_reouverture_dossier, on: :collection
      get :en_attente_validation_cloture_dossier, on: :collection
      get :en_attente_validation_cloture_dossier_tech, on: :collection
      get :en_attente_cloture_dossier, on: :collection
      get :dossiers_clotures, on: :collection
      get :dossiers_reouverts, on: :collection
      get :en_attente_soumission_rechutes, on: :collection
      get :en_attente_validation_rechutes_mc, on: :collection
      get :en_attente_validation_rechutes, on: :collection
      post :add_consolidation
      get :valide_info_consolidation
      get :valide_documents_consolidation
      get :valider_tableau_rente
      get :valider_information_salaire
      get :soumettre_consolidation
      get :soumettre_consolidation_mc
      get :valider_consolidation
      get :confirmer_taux_ipp
      put :modifier_taux_ipp
      get :en_attente_confirmation_consolidation, on: :collection
      get :dossiers_rct, on: :collection
      get :dossiers_rejetes, on: :collection

      resource :at_base_reversion_rentes
      resource :at_salaires
      post :add_frais_engage
      resources :at_frais_engages do
        get :liquider
        get :valider
        get :valider_medecin
        get :valider_comptable
        patch :rejeter   
        get :activer
        get :show_recu
      end
      post :add_incapacite
      resources :at_incapacites do
        get :liquider
        get :valider
        get :valider_medecin
        get :valider_comptable
      end
      post :ajouter_lesion
      resources :at_lesions
      post :ajouter_carnet
      resources :at_carnets
      post :add_decompte
      resources :at_decomptes do
        get :liquider
        get :valider
        get :activer
        get :valider_medecin
        get :valider_comptable
        get :show_recu
        patch :rejeter
        patch :add_documents
        get :annuler_liquidation
        patch :convoquer
      end

      resources :at_rechutes do
        get :soumettre
      end
      resources :at_guerisons
    
      post :add_avi
      resources :at_avis do
      end
      patch :retourner_process
      #post :add_incapacite
      #patch :affectation_multiple, on: :collection
      collection do
        post 'affectation_multiple'
      end
      get :soumettre_avis_redacteur
      get :soumettre_avis_dajc
      get :soumettre_avis_chefService
      patch :active_avis_medecin
      patch :active_avis_dprp
      get :soumettre_avis_medecin
      get :soumettre_avis_dprp
      resources :at_code_prime_salaires
      patch :retourner_redacteur
      resources :at_consolidations do
        get :valider_information_consolidation
        get :valider_documents
        get :valider_onglet_tableau_rente
        get :valider_information_salaire
        get :soumettre
        get :soumettre_chef_service
        get :soumettre_medecin_conseil
        put :decision_medecin_conseil
        get :valider_onglet_decision_mc
        get :validation_mc
        get :verification_tableau_rente
        patch :affectation_technicien
        get :validation_chef_agence
        get :validation_chef_service_at
        get :validation_directeur_at
        get :validation_audit
        get :validation_directeur_general
       
      end

      resources :at_rente_familles do
        get :valider_information_defunt
        get :valider_documents
        get :valider_onglet_tableau_rente
        get :valider_information_salaire
        get :soumettre
        get :soumettre_chef_service
        get :verification_tableau_rente
        patch :affectation_technicien

        get :validation_chef_agence
        get :validation_chef_service_at
        get :validation_directeur_at

      end

    end

    scope '/at_vente_carnets' do
      get '/employeur_carnet/:numero_employeur/:numero_carnet' => 'at_vente_carnets#employeur_carnet', as: :employeur_carnet
    end

    resources :at_vente_carnets
    resources :at_consolidations do
      patch :retourner_process
      get :notification
      get :accord_ipp
      get :en_attente_soumission, on: :collection
      get :consolidations_soumises_chef_agence, on: :collection
      get :consolidations_soumises_chef_service, on: :collection
      get :en_attente_validation_mc, on: :collection
      get :en_attente_affectation_tech, on: :collection
      get :en_attente_verification, on: :collection
      get :en_attente_validation_chef_agence, on: :collection
      get :en_attente_validation_chef_service_at, on: :collection
      get :en_attente_validation_dir_at, on: :collection
      get :en_attente_validation_audit, on: :collection
      get :en_attente_validation_dg, on: :collection
      get :en_attente_validation_direction, on: :collection
      get :en_attente_validation_agence, on: :collection
      post :add_salaire
      resources :at_salaires do
        resources :at_code_prime_salaires
      end
    end
    resources :at_rente_familles do 
      get :valider_epouses
      get :valider_enfants
      get :valider_information_salaire
      get :soumettre
      get :validation_chef_agence
      get :validation_chef_service
      get :validation_directeur_at
      get :validation_audit
      get :validation_directeur_general
      patch :affectation_technicien
      patch :soumettre_orphelins
      patch :soumettre_veuves
      patch :retourner_dossier
      get :en_attente_soumission, on: :collection
      get :soumis_chef_agence, on: :collection
      get :soumis_chef_service, on: :collection
      get :en_attente_validation_dg, on: :collection
      get :en_attente_validation_dir_at, on: :collection
      get :en_attente_verification, on: :collection
      get :en_attente_validation_audit, on: :collection

      post :add_salaire
      resources :at_salaires do
      end
    end

    resources :at_rechutes do 
      get :valider_documents
      get :valider_information_generale
      get :valider_information_salaire
      get :soumettre
      get :validation_chef_agence
      get :validation_chef_service
      get :validation_avis_mc
      get :validation_directeur_at
      get :rejet_directeur_at
      patch :affectation_technicien
      get :en_attente_soumission, on: :collection
      get :en_attente_validation_agence, on: :collection
      get :soumis_chef_service, on: :collection
      get :en_attente_verification, on: :collection
      get :en_attente_validation_dir_at, on: :collection
      get :en_attente_avis_mc, on: :collection
      post :ajouter_element_salaire
      resources :at_code_prime_salaires
      patch :rejet_dossier
      patch :retourner_dossier
    end
    
    resources :at_guerisons do
      get :valider_documents
      get :valider_information_generale
      get :soumettre
      get :validation_chef_agence
      get :validation_chef_service
      patch :rejet_dossier
      patch :retourner_dossier
      get :en_attente_soumission, on: :collection
      get :soumis_chef_agence, on: :collection
      get :soumis_chef_service, on: :collection
      get :mes_dossiers_en_creations, on: :collection
      get :dossiers_retournes, on: :collection
    end



    resources :at_dossier_reversion_rentes do
      get :valider_info_reversion
      get :valider_documents
      get :soumettre
      get :valider
      get :notification
    end

      resources :at_carnets do
      end

    resources :maladie_professionnelles do
      delete '/mp_documents/:id' => 'maladie_professionnelles#delete_document'
    end

    resources :agences, :paiements

    resources :conjoints do
      get :en_attente, on: :collection
      get :valider
      get :rejeter
      get :valides, on: :collection
      get :edit_incomplete
      get :set_complete
      patch :update_incomplete
      get '/active_divorce/:id' => 'conjoints#active_divorce', as: :active_divorce
      get '/active_deces_conjoint/:id' => 'conjoints#active_deces_conjoint', as: :active_deces_conjoint
      get '/active_divorce_conjoint/:id' => 'conjoints#active_divorce_conjoint', as: :active_divorce_conjoint
    end

    scope '/conjoints' do
      get '/listconjoint/:numero_affiliation' => 'conjoints#listconjoint', as: :listconjoint
      get '/listsalaries/:numero_affiliation' => 'conjoints#listsalaries', as: :listsalaries
      get '/salaries/:numero_affiliation' => 'conjoints#infos_salaries', as: :infos_salaries
      get '/conjoint/:numero_piece' => 'conjoints#infos_conjoint', as: :infos_conjoint
    end

    resources :enfants do
      get :en_attente, on: :collection
      get :valider
      get :rejeter
      get :edit_incomplete
      get :set_complete
      patch :update_incomplete
      get '/active_deces/:id' => 'enfants#active_deces', as: :active_deces
    end

    scope '/enfants' do
      get '/listenfant/:numero_affiliation' => 'enfants#listenfant', as: :listenfant
      get '/edit_enfant/:numero_affiliation' => 'enfants#edit_enfant', as: :edit_enfant
    end
   

    resources :declaration_divorce_ou_deces_conjoints

    resources :deces_enfants

    resources :deces_salaries

    resources :update_grappe_familiales do
      get :en_attente, on: :collection
      get :valider
      get :rejeter
    end


    resources :liquidation_retraites do
      get :valider_etat_civil_demandeur
      get :valider_epouses
      get :valider_enfants
      get :valider_carriere
      get :valider_all_carrieres
      get :valider_ligne_carriere
      post :rejeter_ligne_carriere
      get :rejeter_ligne_carriere
      get :rembourser_ligne_carriere
      get :valider_recapitulatif
      get :valider_documents
      post :create_document
      delete '/delete_document/:document_liquidation_retraites_id' => 'liquidation_retraites#destroy_document', as: :destroy_document
      get 'facture_liquidation/facture_liquidation_retraite_id' => 'liquidation_retraites#show_facture', as: :show_facture

      get :soumettre

      get :en_attente, on: :collection
      get :demandes_affectees, on: :collection
      get :carriere_en_attente, on: :collection
      get :recap_en_attente, on: :collection
      get :validation_en_attente, on: :collection
      get :en_attente_validation, on: :collection
      get :ajoutee, on: :collection
      get :valider
      patch :affecter_allocataire
      patch :affecter_salarie
      patch :update_fullname
      patch :activer_dossier_incomplet
      get :affecter_allocataire_all, on: :collection
      get :affecter_salarie_all, on: :collection
      get :rejeter
      get :retour
      patch :rejeter_create

      patch :retourner_process



      patch :soumettre_action
      patch :instruire_action
      patch :valider_carriere_action
      patch :cotisation_valide_action

      patch :valider_recapitulatif_action
      patch :liquidation_valide_action
      patch :dossier_valide_action

      patch :rejeter_process

      get :instruire
      get :carriere_soumis
      get :cotisation_valide
      get :recap_valide
      get :liquidation_valide
      get :dossier_valide
      get :dossier_rejete
      get :soumettre_ligne_carriere
      get :annuler_ligne_carriere
      post :ajouter_carriere
      resources :carrieres do
      end



      get 'lettre_notification' => 'liquidation_retraites#lettre_notification', as: :lettre_notification
      get :dossiers_retournes, on: :collection
      get :dossiers_incomplets, on: :collection

      
    end


    resources :liquidation_retraite_frances do
      get :valider_etat_civil_demandeur
      get :valider_epouses
      get :valider_enfants
      get :valider_carriere
      get :valider_all_carrieres
      get :valider_ligne_carriere
      post :rejeter_ligne_carriere
      get :rejeter_ligne_carriere
      get :valider_activite_prof_valid
      get :valider_assur_residence_valid
      get :valider_assur_second_pays_valid
      get :valider_ressources_conjoint_valid
      get :valider_charge_second_pays_valid
      get :rembourser_ligne_carriere
      get :valider_recapitulatif
      get :valider_documents
      post :ajouter_employeur_ext
      post :ajouter_carrires_prest_exterieure
      post :ajouter_periode_assurance_PR
      post :ajouter_periode_assurance_SP
      post :ajouter_revenu_conjoint
      post :ajouter_bien_pers_conjoint
      post :ajouter_donation_conjoint
      post :ajouter_cfs_conjoint
      # get :valider_conjoint
      # get :rejeter_conjoint
      post :ajouter_cfs_correspondance
      # post :details_cfs_conjoint
      post :ajouter_cfs_enfant
      post :create_document
      delete '/delete_document/:document_liquidation_retraite_frances_id' => 'liquidation_retraite_frances#destroy_document', as: :destroy_document
      delete '/delete_carrieres_exterieure/:carrieres_exterieure_id' => 'liquidation_retraite_frances#destroy_carrieres_exterieure', as: :destroy_carrieres_exterieure
      delete '/delete_periode_assurance/:periode_assurance_id' => 'liquidation_retraite_frances#destroy_periode_assurance', as: :destroy_periode_assurance
      delete '/delete_revenu_conjoint/:revenu_conjoint_id' => 'liquidation_retraite_frances#destroy_revenu_conjoint', as: :destroy_revenu_conjoint
      delete '/delete_bien_pers_conjoint/:bien_pers_conjoint_id' => 'liquidation_retraite_frances#destroy_bien_pers_conjoint', as: :destroy_bien_pers_conjoint
      delete '/delete_donation_conjoint/:donation_conjoint_id' => 'liquidation_retraite_frances#destroy_donation_conjoint', as: :destroy_donation_conjoint
      delete '/delete_cfs_conjoint/:cfs_conjoint_id' => 'liquidation_retraite_frances#destroy_cfs_conjoint', as: :destroy_cfs_conjoint
      delete '/delete_cfs_enfant/:cfs_enfant_id' => 'liquidation_retraite_frances#destroy_cfs_enfant', as: :destroy_cfs_enfant
      delete '/delete_cfs_correspondance/:cfs_correspondance_id' => 'liquidation_retraite_frances#destroy_cfs_correspondance', as: :destroy_cfs_correspondance
      get 'facture_liquidation/facture_liquidation_retraite_france_id' => 'liquidation_retraite_frances#show_facture', as: :show_facture
      get 'formulaire_liquidation/formulaire_liquidation_retraite_france_id' => 'liquidation_retraite_frances#show_formulaire', as: :show_formulaire
      get 'details_cfs_conjoint/:cfs_conjoint_id' => 'liquidation_retraite_frances#details_cfs_conjoint', as: :details_cfs_conjoint

      get :soumettre

      get :en_attente, on: :collection
      get :demandes_affectees, on: :collection
      get :carriere_en_attente, on: :collection
      get :recap_en_attente, on: :collection
      get :validation_en_attente, on: :collection
      get :en_attente_validation, on: :collection
      get :ajoutee, on: :collection
      get :valider
      patch :affecter_allocataire
      patch :affecter_salarie
      patch :update_fullname
      patch :activer_dossier_incomplet
      get :affecter_allocataire_all, on: :collection
      get :affecter_salarie_all, on: :collection
      get :rejeter
      get :retour
      patch :rejeter_create

      patch :retourner_process

      patch :soumettre_action
      patch :instruire_action
      patch :valider_carriere_action
      patch :cotisation_valide_action

      patch :valider_recapitulatif_action
      patch :liquidation_valide_action
      patch :dossier_valide_action

      patch :rejeter_process

      get :instruire
      get :carriere_soumis
      get :cotisation_valide
      get :recap_valide
      get :liquidation_valide
      get :dossier_valide
      get :dossier_rejete
      get :soumettre_ligne_carriere
      get :annuler_ligne_carriere
      post :ajouter_carriere
      get :valider_ligne_carriere_ext
      get :rejeter_ligne_carriere_ext
      resources :carrieres do
      end

      get 'lettre_notification' => 'liquidation_retraite_frances#lettre_notification', as: :lettre_notification
      get :dossiers_retournes, on: :collection
      get :dossiers_incomplets, on: :collection


    end
    # Start Prestation exterieure CAF
    resources :prestation_exterieures do
      post :create_caf_conjoint
      post :create_caf_enfant
      patch :replace_extrait
      post :create_document
      get :valider_documents
      get :valider_informations
      get :valider_conjoints
      get :valider_enfants
      get :valider_indemnites
      get :valider
      get :reouvrir_conjoints
      get :reouvrir_enfants
      get :reouvrir_indemnites
      get :soumettre_etat_famille
      get :valider_etat_famille
      patch :rejeter_etat_famille
      get :reouvrir_dossier
      post :ajouter_indemnites
      patch :add_numero_caf
      patch :add_caisse_caf
      get :add_beneficiary
      get :remove_beneficiary

      get :soumettre_droit_liquidation
      get :valider_par_chef_groupe
      get :valider_par_chef_subdivision
      patch :rejeter_dt_liq
      get :valider_par_comptable

      get :renouveler_pieces
      get :modifier_dossier
      get :grappe_familliale
      get :historique_dossier

      get :add_conjoint
      get :add_enfant

      get :suspendre_dossier

      patch 'retourner_indemnite/:indemnites_id' => 'prestation_exterieures#retourner_indemnite', as: :retourner_indemnite
      patch 'modifier_indemnites/:indemnites_id' => 'prestation_exterieures#modifier_indemnites', as: :modifier_indemnites
      get '/liquider_indemnites/:indemnites_id' => 'prestation_exterieures#liquider_indemnites', as: :liquider_indemnites
      get '/liquider_x_indemnites_ges_cpt/' => 'prestation_exterieures#liquider_x_indemnites_ges_cpt', as: :liquider_x_indemnites_ges_cpt
      get '/valider_indemnites_chef_grp/:indemnites_id' => 'prestation_exterieures#valider_indemnites_chef_grp', as: :valider_indemnites_chef_grp
      get '/valider_x_indemnites_chef_grp/' => 'prestation_exterieures#valider_x_indemnites_chef_grp', as: :valider_x_indemnites_chef_grp
      get '/valider_x_indemnites_chef_sub/' => 'prestation_exterieures#valider_x_indemnites_chef_sub', as: :valider_x_indemnites_chef_sub
      get '/valider_x_indemnites_chef_cpt/' => 'prestation_exterieures#valider_x_indemnites_chef_cpt', as: :valider_x_indemnites_chef_cpt
      get '/valider_indemnites_chef_sub/:indemnites_id' => 'prestation_exterieures#valider_indemnites_chef_sub', as: :valider_indemnites_chef_sub
      get '/valider_indemnites_comptable/:indemnites_id' => 'prestation_exterieures#valider_indemnites_comptable', as: :valider_indemnites_comptable
      patch '/update_indemnites/:indemnites_id' => 'prestation_exterieures#update_indemnites', as: :update_indemnites
      delete '/delete_indemnites/:indemnites_id' => 'prestation_exterieures#destroy_indemnites', as: :destroy_indemnites
      get '/update_document_form/:document_prestation_exterieure_id' => 'prestation_exterieures#update_document_form', as: :update_document_form
      patch '/update_document/:document_prestation_exterieure_id' => 'prestation_exterieures#update_document', as: :update_document
      delete '/delete_document/:document_prestation_exterieure_id' => 'prestation_exterieures#destroy_document', as: :destroy_document

      get 'generate_etat/' => 'prestation_exterieures#generate_etat', as: :generate_etat
      get 'ordre_paiement/:conjoint_id/:d_debut/:d_fin' => 'prestation_exterieures#ordre_paiement', as: :ordre_paiement
      get 'recipisse_depot/' => 'prestation_exterieures#recipisse_depot', as: :recipisse_depot

      get 'show_conjoint/:conjoint_id' => 'prestation_exterieures#show_conjoint', as: :show_conjoint
      get 'show_enfant/:enfant_id' => 'prestation_exterieures#show_enfant', as: :show_enfant

      get 'edit_conjoint/:conjoint_id' => 'prestation_exterieures#edit_conjoint', as: :edit_conjoint
      get 'edit_enfant/:enfant_id' => 'prestation_exterieures#edit_enfant', as: :edit_enfant

      patch 'update_caf_conjoint/:conjoint_id' => 'prestation_exterieures#update_caf_conjoint', as: :update_caf_conjoint
      patch 'update_caf_enfant/:enfant_id' => 'prestation_exterieures#update_caf_enfant', as: :update_caf_enfant

      delete 'delete_caf_conjoint/:conjoint_id' => 'prestation_exterieures#delete_caf_conjoint', as: :delete_caf_conjoint
      delete 'delete_caf_enfant/:enfant_id' => 'prestation_exterieures#delete_caf_enfant', as: :delete_caf_enfant

      get 'activate_caf_enfant/:enfant_id' => 'prestation_exterieures#activate_caf_enfant', as: :activate_caf_enfant
      get 'deactivate_caf_enfant/:enfant_id' => 'prestation_exterieures#deactivate_caf_enfant', as: :deactivate_caf_enfant
    end

    scope '/caf_conjoints' do
      get '/list_caf_conjoints/:id' => 'prestation_exterieures#list_caf_conjoints', as: :list_caf_conjoints
    end

    scope '/prestation_exterieures' do
      get '/validation/etats_famille/' => 'prestation_exterieures#etats_famille', as: :etats_famille
      get '/validation/droits_liquidation/' => 'prestation_exterieures#droits_liquidation', as: :droits_liquidation
      get '/validation/droits_liquidation/:id' => 'prestation_exterieures#droits_liquidation_details', as: :droits_liquidation_details
      get '/etat_famille/en_attente_allocation/' => 'prestation_exterieures#en_attente_allocation', as: :en_attente_allocation
      get '/etat_famille/en_attente_paiement/' => 'prestation_exterieures#en_attente_paiement', as: :en_attente_paiement
      post '/fill_start_and_end_date', to: 'prestation_exterieures#fill_start_and_end_date'
    end

    # End Prestation exterieur CAF

    resources :at_code_prime_salaires do
      get :en_attente, on: :collection
      get :valider
      get :rejeter
    end
    resources :composant_salaires

    resources :css_annulation_paiements do
      patch :marquer_impaye
      get :rendre_impaye
      get :annuler_impaye
      get :en_attente_validation_impayes, on: :collection
    end

    resources :dossier_prestations do
      get :valider_etat_civil_demandeur
      get :valider_enfants
      get :valider_carriere
      get :valider_documents
      post :create_document
      post :create_document_tdp
      #patch :update_document_tdp
      get :historique_dossier
      get :maintien_prestations
      post :create_maintien_prestations
      get :list_dossier_conjoint
      get :all_regularisation
      get :individual_regularisation_af
      get :regularisation_after_term
      get :regularisation_widow
      post :create_cloture_request
      post :create_attributaire_tierce
      get :attributaire_tierce_en_attente, on: :collection

      get 'initiate_widow_regularization/:trimestre/:annee' => 'dossier_prestations#initiate_widow_regularization', as: :initiate_widow_regularization
      get 'regularisation_widow_details/:trimestre/:annee' => 'dossier_prestations#regularisation_widow_details', as: :regularisation_widow_details
      get 'regularisation_after_term_details/:trimestre/:annee' => 'dossier_prestations#regularisation_after_term_details', as: :regularisation_after_term_details
      get 'regularisation_widow_pay_child/:enfant_id/:nbr_month_left/:trimestre/:annee' => 'dossier_prestations#regularisation_widow_pay_child', as: :regularisation_widow_pay_child
      get 'regularisation_after_term_pay_child/:enfant_id/:nbr_month_left/:trimestre/:annee/:echeance_dossier_id' => 'dossier_prestations#regularisation_after_term_pay_child', as: :regularisation_after_term_pay_child
      get 'individual_regularisation_af_details/:trimestre/:annee' => 'dossier_prestations#individual_regularisation_af_details', as: :individual_regularisation_af_details
      get 'individual_regularisation_pay_child/:enfant_id/:trimestre/:annee' => 'dossier_prestations#individual_regularisation_pay_child', as: :individual_regularisation_pay_child
      get 'detail_allocation_familiale_migree/:allocation_id' => 'dossier_prestations#detail_allocation_familiale_migree', as: :detail_allocation_familiale_migree
      get 'detail_allocation_prenatales_migree/:allocation_id' => 'dossier_prestations#detail_allocation_prenatales_migree', as: :detail_allocation_prenatales_migree
      get 'detail_allocation_postnatale_migree/:allocation_id' => 'dossier_prestations#detail_allocation_postnatale_migree', as: :detail_allocation_postnatale_migree
      get 'renewal_child_documents/:child_id' => 'dossier_prestations#renewal_child_documents', as: :renewal_child_documents
      get 'renewal_documents_historic' => 'dossier_prestations#renewal_documents_historic', as: :renewal_documents_historic
      get 'dossier_prestation_historics' => 'dossier_prestations#dossier_prestation_historics', as: :dossier_prestation_historics
      get 'details_pf_historics/:pf_historics_id' => 'dossier_prestations#details_pf_historics', as: :details_pf_historics
      get 'delete_beneficiary/pre_post' => 'dossier_prestations#delete_beneficiary_pre_post', as: :delete_beneficiary_pre_post
      get 'add_beneficiary/pre_post' => 'dossier_prestations#add_beneficiary_pre_post', as: :add_beneficiary_pre_post
      get 'add_beneficiary/:conjoint_id' => 'dossier_prestations#add_beneficiary', as: :add_beneficiary
      get 'remove_beneficiary/:conjoint_id' => 'dossier_prestations#remove_beneficiary', as: :remove_beneficiary
      get 'dossier_conjoint/:conjoint_id' => 'dossier_prestations#create_dossier_conjoint', as: :create_dossier_conjoint
      get 'edit/carriere/:carriere_id' => 'dossier_prestations#edit_carriere', as: :edit_carriere
      delete '/delete_carriere/:carriere_id' => 'dossier_prestations#delete_carriere', as: :delete_carriere
      patch '/update/carriere/:carriere_id' => 'dossier_prestations#update_document_tdp', as: :update_document_tdp
      get '/update_document_form/:document_dossier_prestation_id' => 'dossier_prestations#update_document_form', as: :update_document_form
      patch '/update_document/:document_dossier_prestation_id' => 'dossier_prestations#update_document', as: :update_document
      delete '/delete_document/:document_dossier_prestation_id' => 'dossier_prestations#destroy_document', as: :destroy_document
      get 'recipisse_dossier_prestation' => 'dossier_prestations#recipisse_dossier', as: :recipisse_dossier
      get '/cancel_maintien_prestation/:maintien_id' => 'dossier_prestations#cancel_maintien_prestation', as: :cancel_maintien_prestation
      get '/delete_maintien_prestation/:maintien_id' => 'dossier_prestations#delete_maintien_prestation', as: :delete_maintien_prestation
      get 'liquider_familiales_by_period/:annee/:trimestre' => 'dossier_prestations#liquider_familiales_by_period', as: :liquider_familiales_by_period
      get 'liquider_familiales_by_year/:annee' => 'dossier_prestations#liquider_familiales_by_period', as: :liquider_familiales_by_year
      get '/affecter_dossier/:agent_id' => 'dossier_prestations#affecter_dossier', as: :affecter_dossier
      get '/annuler_affectation_dossier/:agent_id' => 'dossier_prestations#annuler_affectation_dossier', as: :annuler_affectation_dossier
      get 'cloturer/:request_id' => 'dossier_prestations#cloturer', as: :cloturer
      patch '/cancel_cloture_request/:request_id' => 'dossier_prestations#cancel_cloture_request', as: :cancel_cloture_request
      delete '/destroy_attributaire_tierce/:at_id' => 'dossier_prestations#destroy_attributaire_tierce', as: :destroy_attributaire_tierce
      get '/soumettre_attributaire_tierce/:at_id' => 'dossier_prestations#soumettre_attributaire_tierce', as: :soumettre_attributaire_tierce
      get '/valider_attributaire_tierce/:at_id' => 'dossier_prestations#valider_attributaire_tierce', as: :valider_attributaire_tierce
      patch '/rejeter_attributaire_tierce/:at_id' => 'dossier_prestations#rejeter_attributaire_tierce', as: :rejeter_attributaire_tierce

      get :soumission_form
      get :soumettre
      get :enregistrer
      get :valider_paiement

      get 'facture_liquidation/facture_liquidation_retraite_id' => 'liquidation_retraites#show_facture', as: :show_facture
      get '/allocatairespf/:allocatairespf_id' => 'dossier_prestations#details_allocatairespf', as: :details_allocatairespf

      get :en_attente, on: :collection
      get :attente_validation_postnatale, on: :collection
      get :attente_validation_prenatale, on: :collection
      get :attente_validation_familiale, on: :collection
      get :clotures_requests, on: :collection
      get :valider_ordre, on: :collection
      get :valider_prenatales
      get :valider_postnatales
      get :valider_x_postnatales, on: :collection
      get :valider_x_paiement, on: :collection
      get :valider_familiales
      get :rejeter_familiales
      patch :rejeter_familiales
      get :liquider_postnatales
      get :liquider_prenatales
      get :liquider_familiales
      get :ajoutee, on: :collection
      get :incomplete_dossiers, on: :collection
      get :edit_incomplete
      get :set_complete
      patch :update_incomplete
      get :anciens_dossiers, on: :collection
      get :nouveaux_dossiers, on: :collection
      get :valider
      get :rejeter
      post :retour_process
      get :retour
      get :allocation_en_attente, on: :collection
      patch :rejeter_create
      get :edit_specially
      patch :update_specially

      resources :dossier_prestation_avis_tiers do
        get :soumettre
        get :valider
        patch :retourner
        get :valider_paiement
      end

      resources :beneficiary_associations_to_dps do

      end

      resources :grossesses do
        get :interruption_form
      end

      resources :allocation_prenatales do
        get :soumission_form
        get :soumettre
        get :valider
        get :attente_validation
        patch :retour_volet
        get :retour
        get :rejet_volet
        post :motif_rejet
      end

      resources :allocation_postnatales do
        get :soumission_form
        get :soumettre
        patch :retour_volet
        get :retour
        get :valider
        get :attente_validation
      end

      resources :allocation_familiales do
        get :soumission_form
        get :soumettre

        post :create_document
        get :valider_documents

        get :valider
        get :attente_validation

        patch :motif_rejet
        get :rejeter
        patch :rejeter
        patch :retourner
      end
      get '/allocation_familiales/carriere/:annee' => 'allocation_familiales#get_carrieres', as: :get_carrieres

    end

    resources :beneficiary_associations_to_dps

    scope '/dossier_prestations' do
      get '/employeur/:fhnum' => 'dossier_prestations#show_raison_social', as: :show_raison_social
    end

    # Prestations Extérieures France (CFS)
    resources :cfs_reversion_veuves do
      get :valider_etat_civil_demandeur
      get :valider_grappe_familiale
      get :valider_activite_prof_valid
      get :valider_assur_residence_valid
      get :valider_assur_second_pays_valid
      get :valider_charge_second_pays_valid
      get :valider_all_carrieres
      get :valider_ligne_carriere
      get :rejeter_ligne_carriere
      get :valider_recapitulatif
      get :valider_documents
      post :create_document
      get :historique_dossier
      get :valider_epouses
      get :valider_enfants

      get 'recipisse_prestation_ext_france' => 'prestation_ext_frances#recipisse_dossier', as: :recipisse_dossier

      get :soumission_form
      get :soumettre
      get :enregistrer
      get :valider_paiement

      get 'facture_prestation_ext/facture_cfs_reversion_veuve_id' => 'cfs_reversion_veuves#show_facture', as: :show_facture

      get :valider_ordre, on: :collection

      get :en_attente, on: :collection
      get :carriere_en_attente, on: :collection
      get :recap_en_attente, on: :collection
      get :ajoutee, on: :collection
      get :valider
      patch :affecter_allocataire
      patch :affecter_salarie
      get :affecter_allocataire_all, on: :collection
      get :affecter_salarie_all, on: :collection
      get :rejeter
      get :retour
      patch :rejeter_create
      patch :retourner_process
      get :instruire
      get :carriere_soumis
      get :cotisation_valide
      get :recap_valide
      get :liquidation_valide
      get :dossier_valide
      get :dossier_rejete
      post :ajouter_carriere
      post :ajouter_employeur_ext
      post :ajouter_carrires_prest_exterieure
      post :ajouter_periode_assurance_PR
      post :ajouter_periode_assurance_SP

      get :en_attente_instruction, on: :collection
      get :en_attente_affectation_salarie, on: :collection
      get :en_attente_affectation_allocataire, on: :collection
      get :en_attente_validation_allocataire, on: :collection
      get :en_attente_validation_salaire, on: :collection
      get :en_attente_validation_carriere, on: :collection
      get :en_attente_validation_recap, on: :collection
      get :en_attente_validation, on: :collection
      get :valider_ligne_carriere_ext
      get :rejeter_ligne_carriere_ext

      # resources :periode_assurances do
      # end
      delete '/delete_periode_assurance/:periode_assurance_id' => 'cfs_reversion_veuves#destroy_periode_assurance', as: :destroy_periode_assurance
    end

    resources :carrieres_exterieures do
    end

    # End Prestations Extérieures France (CFS)

    resources :allocataire_pf do
      get :allocation_per_salarie
      get :maintien_prestations
      post :create_maintien_prestations
    end

    # Start traitement collectif

    resources :traitement_collectifs do
      get 'voir_bordereau/:annee/:trimestre' => 'traitement_collectifs#voir_bordereau', as: :voir_bordereau
      post 'generate_bordereau/:annee/:trimestre/' => 'traitement_collectifs#generate_bordereau', as: :generate_bordereau
      post 'create_carrieres_dp/:num_bordereau/:num_affiliation' => 'traitement_collectifs#create_carrieres_dp', as: :create_carrieres_dp
      patch 'update_carrieres_dp/:num_bordereau/:num_affiliation/:id_carriere' => 'traitement_collectifs#update_carrieres_dp', as: :update_carrieres_dp
      get :list_bordereau
      get 'ouvrir_bordereau/:num_bordereau/' => 'traitement_collectifs#ouvrir_bordereau', as: :ouvrir_bordereau
      get 'generer_bordereau_complementaire/:num_bordereau/' => 'traitement_collectifs#generate_complementary_bordereau', as: :generer_bordereau_complementaire
      get 'liquider_bordereau/:num_bordereau/' => 'traitement_collectifs#liquider_bordereau', as: :liquider_bordereau
      get 'valider_bordereau/:num_bordereau/' => 'traitement_collectifs#valider_bordereau', as: :valider_bordereau
      patch 'retourner_bordereau/:num_bordereau/' => 'traitement_collectifs#retourner_bordereau', as: :retourner_bordereau
      get 'voir_paiement/:num_bordereau/' => 'traitement_collectifs#voir_paiement', as: :voir_paiement
      get 'valider_paiement/:num_bordereau/' => 'traitement_collectifs#valider_paiement', as: :valider_paiement
      get 'envoyer_bordereau/:num_bordereau/' => 'traitement_collectifs#envoyer_bordereau', as: :envoyer_bordereau
      get 'fill_all_carriers/:num_bordereau/' => 'traitement_collectifs#fill_all_carriers', as: :fill_all_carriers
      get 'clear_all_carriers/:num_bordereau/' => 'traitement_collectifs#clear_all_carriers', as: :clear_all_carriers
    end

    scope '/traitement_collectifs' do
      get '/tr/en_attente/' => 'traitement_collectifs#en_attente', as: :tr_en_attente
      get '/tr/veuves/en_attente/' => 'traitement_collectifs#tr_veuves_en_attente', as: :tr_veuves_en_attente
      get '/tr/options_list/' => 'traitement_collectifs#options_list', as: :options_list
      get '/tr/allocations_list/' => 'traitement_collectifs#allocations_list', as: :allocations_list
      post '/liquider_allocations_from_maintien/:annee/:trimestre/' => 'traitement_collectifs#liquider_allocations_from_maintien', as: :liquider_allocations_from_maintien
      post '/valider_allocations_from_maintien/:annee/:trimestre/' => 'traitement_collectifs#valider_allocations_from_maintien', as: :valider_allocations_from_maintien
      post '/valider_paiement_from_maintien/:annee/:trimestre/' => 'traitement_collectifs#valider_paiement_from_maintien', as: :valider_paiement_from_maintien

      post '/valider_allocations_from_maintien_en_attente/' => 'traitement_collectifs#valider_allocations_from_maintien', as: :valider_allocations_from_maintien_en_attente
      post '/valider_paiement_from_maintien_en_attente/' => 'traitement_collectifs#valider_paiement_from_maintien', as: :valider_paiement_from_maintien_en_attente

      get '/generate_all_bordereau/:trimestre/:annee/' => 'traitement_collectifs#generate_all_bordereau', as: :generate_all_bordereau
      get '/tr/liquider_all_bordereau/' => 'traitement_collectifs#liquider_all_bordereau', as: :liquider_all_bordereau
    end

    # Start traitement collectif


    # Start mandataires

    resources :mandataires do

     end

    resources :dossier_cnavs do
      get :historique_dossier
      get :soumettre
      get :charger
      get :valider_allocataires
      get :liquider_allocataires
      get :supprimer_allocataires
      get :valider_paiement
      #get :consulter_delta

      get :valider_liquid_allocataires
      get :valider_inspec_allocataires

      get :rapport_controle_form
      patch :rapport_controle_soumettre

      get :en_attente, on: :collection
      get :valider_ordre, on: :collection
      get :ajoutee, on: :collection
      get :valider
      get :rejeter
      get :valider_liquidation
      get :rejeter_liquidation
      get :valider_inspection
      get :rejeter_inspection
      patch :rejeter_create
      post :retour_process
      get :retour
      patch :affecter_controleur
      get :affecter_controleur_all, on: :collection

      post :import

      resources :allocataire_cnavs do
        get :soumettre
        get :valider
        get :rejeter
        get :valider_liquidation
        get :rejeter_liquidation
        get :valider_inspection
        get :rejeter_inspection
        #get :valider_paiement_compt
        get :retour

      end

    end



    resources :dossier_maternites do
      get :valider_etat_civil_demandeur
      get :valider_carriere
      get :valider_documents
      get :valider_salaire
      post :create_document
      post :create_composant
      post :create_document_tdp
      get :historique_dossier
      get :enregistrer
      get :valider_paiement
      get :admin_edit
      patch :admin_edit_except
      get :icm_tranches_historic

      get '/update_document_form/:document_dossier_maternite_id' => 'dossier_maternites#update_document_form', as: :update_document_form
      patch '/update_document/:document_dossier_maternite_id' => 'dossier_maternites#update_document', as: :update_document

      delete '/delete_carriere/:carriere_dossier_maternite_id' => 'dossier_maternites#destroy_carriere', as: :destroy_carriere
      delete '/delete_composant/:composant_salaire_icm_id' => 'dossier_maternites#destroy_composant', as: :destroy_composant

      get 'recipisse_dossier_maternites' => 'dossier_maternites#recipisse_dossier', as: :recipisse_maternites

      get '/affecter_dossier_mat/:agent_id' => 'dossier_maternites#affecter_dossier', as: :affecter_dossier_mat
      get '/annuler_affectation_dossier_mat/:agent_id' => 'dossier_maternites#annuler_affectation_dossier', as: :annuler_affectation_dossier_mat

      #patch :soumettre
      get :soumettre
      get :valider_indemnites
      get :liquider_indemnites

      get :rapport_controle_form
      patch :rapport_controle_soumettre

      get :en_attente, on: :collection
      get :valider_ordre, on: :collection
      get :ajoutee, on: :collection
      get :valider
      get :cloturer
      get :rejeter
      patch :rejeter_create
      #post :retour_process
      get :retour
      patch :affecter_controleur
      get :affecter_controleur_all, on: :collection
      patch :retourner_dossier

      resources :indemnite_conges_maternites do
        patch :retourner
        get :soumission_form
        #patch :soumettre
        get :soumettre
        get :valider
        get :rejeter
        #get :valider_paiement_compt
        patch :retour_volet
        get :retour
      end
      resources :icm_modifier_info_personnelles

      resources :dossier_maternite_avis_tiers do
        get :soumettre
        get :valider
        patch :retourner
        get :valider_paiement
      end
    end

    resources :allocation_familiales do
      get :en_attente, on: :collection
      get :index_all, on: :collection
      get :valider
      get :rejeter
      get :option
      patch :rejeter_create
    end

    resources :allocation_prenatales do
      get :en_attente, on: :collection
      get :index_all, on: :collection
      get :valider
      get :rejeter
      patch :rejeter_create
    end

    resources :allocation_postnatales do
      get :en_attente, on: :collection
      get :index_all, on: :collection
      get :valider
      get :rejeter
      patch :rejeter_create
    end

    resources :indemnite_conges_maternites do
      get :en_attente, on: :collection
      get :index_all, on: :collection
      get :valider
      get :rejeter
      patch :rejeter_create
    end

    resources :paiements do
      get 'generer_paiement' => 'paiements#generer_paiement', as: :generer_paiement
      get 'generer_paiement_caf' => 'paiements#generer_paiement_caf', as: :generer_paiement_caf
      get 'generer_paiement_icm' => 'paiements#generer_paiement_icm', as: :generer_paiement_icm
    end

    resources :activite_principales, :statut_juridiques, :convention_collectives, :secteur_activites, :type_employeurs,
              :professions, :pays, :type_contrat_salaries, :baremes, :caf_baremes, :type_regimes, :sites, :temps_travails,
              :mouvement_travails, :mouvement_travail_fins, :countries, :quartiers, :communes, :villes, :departements, :regions, :cities, :bareme_pensions, :type_piece_identifications,
              :type_etablissements, :type_etablissement_diplomatiques, :type_etablissement_publiques, :type_etat_civils,
              :type_statut_juridiques, :motif_sorties, :mouvement_travails, :mouvement_travail_fins, :countries,
              :montant_mensualite_volets, :localite_grappes, :compta_nature_prestations, :tests
    resources :bareme_impots, only: [:index, :show]
    resources :assures, only: [:index, :show]
    resources :assure_tpes, only: [:index, :show]

    resources :enrolements, only: [] do
      get 'regularisations', on: :collection
      get 'regularisations/:regularisation_id', to: 'enrolements#show_regularisation', on: :collection, as: :regularisation
      get 'regularisations/:regularisation_id/paiements', to: 'enrolements#paiements_regularisation', on: :collection, as: :paiements_regularisation
      get 'regularisations/:regularisation_id/valider', to: 'enrolements#valider_regularisation', on: :collection, as: :valider_regularisation
      get 'regularisations/:regularisation_id/rejeter', to: 'enrolements#rejeter_regularisation', on: :collection, as: :rejeter_regularisation
      delete 'regularisations/:regularisation_id/ligne/:regularisation_ligne_id/supprimer', to: 'enrolements#delete_regularisation_ligne', on: :collection, as: :supprimer_regularisation_ligne
    end

    resources :echeance_caisses, only: [:index, :show] do
      get :bordereaux
      get :en_attente, on: :collection
      get 'employeurs/:employeur_id', to: 'echeance_caisses#show_employeur', as: :employeur
      get 'employeurs/:employeur_id/edit', to: 'echeance_caisses#edit_employeur', as: :edit_employeur
      get 'employeurs/:employeur_id/change_statut_employeur/:statut', to: 'echeance_caisses#change_statut_employeur', as: :change_statut_employeur
      patch 'employeurs/:employeur_id/update', to: 'echeance_caisses#update_employeur', as: :update_employeur
      get 'employeurs/:employeur_id/dossier/:dossier_id', to: 'echeance_caisses#show_dossier', as: :dossier
      get 'employeurs/:employeur_id/payment_orders', to: 'echeance_caisses#payment_orders', as: :payment_orders
      get 'employeurs/:employeur_id/:echeance_liquidation/generate_order', to: 'echeance_caisses#generate_order', as: :generate_order
      get 'employeurs/:employeur_id/:echeance_liquidation/generate_payment_order', to: 'echeance_caisses#generate_payment_order', as: :generate_payment_order
      get 'employeurs/:employeur_id/:echeance_liquidation/show_order', to: 'echeance_caisses#show_order', as: :show_order
      patch 'employeurs/:employeur_id/change_statut_employeur_with_motif/:statut', to: 'echeance_caisses#change_statut_employeur', as: :change_statut_employeur_with_motif
      get 'employeurs/:employeur_id/set_individual_payment/:dossier_id', to: 'echeance_caisses#set_individual_payment', as: :set_individual_payment
      get 'employeurs/:employeur_id/remove_individual_payment/:dossier_id', to: 'echeance_caisses#remove_individual_payment', as: :remove_individual_payment
      get 'employeurs/:employeur_id/exclude_from_echeance/:dossier_id', to: 'echeance_caisses#exclude_from_echeance', as: :exclude_from_echeance
    end

    resources :echeance_veuves_caisses, only: [:index, :show] do
      get 'veuves/:veuve_id', to: 'echeance_veuves_caisses#show_veuve', as: :veuve
      get 'change_statut/:statut', to: 'echeance_veuves_caisses#change_statut', as: :change_statut
      patch 'change_statut_with_motif/:statut', to: 'echeance_veuves_caisses#change_statut', as: :change_statut_with_motif
      get 'all_liquidations_slices', to: 'echeance_veuves_caisses#all_liquidations_slices', as: :all_liquidations_slices
      get 'liquidation_details/:liquidation_id', to: 'echeance_veuves_caisses#liquidation_details', as: :liquidation_details
      get 'generer_ordre_paiement/:ordre_id', to: 'echeance_veuves_caisses#generer_ordre_paiement', as: :generer_ordre_paiement
    end

    resources :trackings, only: [:index] do
      get :export, on: :collection, :defaults => { format: :xlsx }
    end

    resources :revision_pensions do
      get :en_attente_affectation_salarie, on: :collection
      get :en_attente_affectation_allocataire, on: :collection
      get :en_attente_validation_allocataire, on: :collection
      get :en_attente_validation_salaire, on: :collection
      get :en_attente_instruction, on: :collection
      get :en_attente_validation_carriere, on: :collection
      get :en_attente_validation_recap, on: :collection
      get :en_attente_validation, on: :collection
      get :en_attente_validation_revision, on: :collection
      get :en_attente_validation_inspection, on: :collection
      get :en_attente_soumission, on: :collection
      get :lettre_notification

    end

    resources :pret_allocataires do
      get :valider
      get :rejeter
      get :en_attente_validation, on: :collection
    end

    resources :demande_remboursement_cotisations do
      get :valider_etat_civil_demandeur
      get :valider_epouses
      get :valider_enfants
      get :valider_carriere
      get :valider_all_carrieres
      get :soumettre_all_carrieres
      get :valider_ligne_carriere
      get :rejeter_ligne_carriere
      get :valider_recapitulatif
      get :valider_documents

      get 'facture_liquidation/facture_liquidation_retraite_id' => 'liquidation_retraites#show_facture', as: :show_facture
      get '/allocatairespf/:allocatairespf_id' => 'dossier_prestations#details_allocatairespf', as: :details_allocatairespf

      get :soumettre

      get :en_attente_affectation_salarie, on: :collection
      get :en_attente_affectation_allocataire, on: :collection
      get :en_attente_validation_allocataire, on: :collection
      get :en_attente_validation_salaire, on: :collection
      get :en_attente_instruction, on: :collection
      get :en_attente_validation_carriere, on: :collection
      get :en_attente_validation_recap, on: :collection
      get :en_attente_validation, on: :collection
      get :en_attente_regularisation_remboursement, on: :collection
      get :en_attente_validation_inspection, on: :collection
      get :ajoutee, on: :collection
      get :valider
      patch :affecter_allocataire
      patch :affecter_salarie
      get :affecter_allocataire_all, on: :collection
      get :affecter_salarie_all, on: :collection
      get :rejeter
      get :retour
      patch :rejeter_create
      patch :retourner_process
      get :instruire
      get :carriere_soumis
      get :cotisation_valide
      get :recap_valide
      get :liquidation_valide
      get :dossier_valide
      get :dossier_rejete
      get :soumettre_ligne_carriere
      get :annuler_ligne_carriere
      get :activer_ligne_carriere
      get :valider_ligne_remboursement
      get :rejeter_ligne_remboursement
      post :ajouter_carriere
      get :regulariser_remboursement
      get :validation_inspection
      get :bordereau_remboursement, on: :collection
      get :show_recue_remboursement
      get :show_facture_remboursement
      get :payment_order
    end

    resources :base_reversion_salaries do
      get :valider_etat_civil_demandeur
      get :valider_documents
      get :valider_epouses
      get :valider_enfants
      get :valider_carriere
      get :valider_all_carrieres
      get :valider_ligne_carriere
      get :rejeter_ligne_carriere
      post :rejeter_ligne_carriere
      get :valider_recapitulatif
      get :soumettre
      get :instruire
      get :carriere_soumis
      get :en_attente_affectation_salarie, on: :collection
      get :en_attente_affectation_allocataire, on: :collection
      get :en_attente_validation_allocataire, on: :collection
      get :en_attente_validation_salaire, on: :collection
      get :en_attente_instruction, on: :collection
      get :en_attente_validation_carriere, on: :collection
      get :en_attente_validation_recap, on: :collection
      get :en_attente_validation, on: :collection
      get :en_attente_regularisation_remboursement, on: :collection
      patch :affecter_allocataire
      patch :affecter_salarie
      get :affecter_allocataire_all, on: :collection
      get :affecter_salarie_all, on: :collection
      get :rejeter
      get :retour
      patch :rejeter_create
      patch :retourner_process
      post :ajouter_carriere
      get :form_base_reversion
      post :soumettre_base_reversion
      get :valider_cotisation
      get :soumettre_recapitulatif
      get :liquidation_valide
      get :dossier_valide
      get :valider
      get :recap_point_valide
      get :dossier_demandeur_valide
      get :show_facture
      get :liste_dossiers_valides, on: :collection
      post :create_dossier_reversion

      patch :soumettre_action
      patch :instruire_action
      patch :valider_carriere_action
      patch :cotisation_valide_action

      patch :valider_recapitulatif_action
      patch :liquidation_valide_action
      patch :dossier_valide_action

      get '/affecter_dossier/:agent_id' => 'base_reversion_salaries#affecter_dossier', as: :affecter_dossier_base_reversion
      get '/annuler_affectation_dossier/:agent_id' => 'base_reversion_salaries#annuler_affectation_dossier', as: :annuler_affectation_dossier_base_reversion

      resources :carrieres do
      end

      get :demandes_affectees, on: :collection
      patch :activer_dossier_incomplet
      get :dossiers_retournes, on: :collection
      get :dossiers_incomplets, on: :collection

      get :exceptional_edit
      patch :update_exceptionally
    end

    resources :dossier_reversion_salaries do
      get :est_eligible
      get :pas_eligible
      get :soumettre
      get :soumettre_recap
      get :valider_recap
      get :valider_dossier
      get :etat_ayant_droit_valide
      get :documents_valide
      get :soumettre_dossier
      get :lettre_notification1

    end

    resources :echeance_paiements, only: [:index, :show] do
      get :confirmer
      get :valdier
      get :rejeter
      get :valider_liquidation
      get :valider_instruction
      get :valider_chef_section
      get :valider_service
      get :valider_directeur
      get :primo_pensionnes
      get :regularisations
      get :revisions
      get :suspensions
      get :sortie_majorations
      get :extinctions
      get :changement_infos
      get :suivi_avis
      get :suivi_avances
      get :comptages
      get :echantillon_paiements
      get :paiements
      get :en_attente_validation_service, on: :collection
      get :en_attente_validation_dp, on: :collection
      get :en_attente_validation_instruction, on: :collection
      get :en_attente_validation_liquidation, on: :collection
      get :changement_mode_paiements
      get :changement_adresses
      get :pension_alimentaires
    end
    resources :ordre_paiements do
      patch :marquer_impaye
      get :rendre_impaye
      get :annuler_impaye
      get :en_attente_validation_impayes, on: :collection
    end

    resources :modifier_mode_paiements do
      get :en_attente_soumission, on: :collection
      get :en_attente_affectation, on: :collection
      get :en_attente_verification, on: :collection
      get :en_attente_validation, on: :collection
      get :mes_affectations, on: :collection
      get :toutes_les_demandes, on: :collection
      get :en_attente_validation_agence, on: :collection
      get :toutes_les_demandes_en_agence, on: :collection
      
      collection do
        post 'affectation_multiple'
      end
    end
    resources :modifier_adresses do
      get :en_attente_soumission, on: :collection
      get :en_attente_affectation, on: :collection
      get :en_attente_verification, on: :collection
      get :en_attente_validation, on: :collection
     
    end

    resources :suspension_allocataires do
      get :en_attente_soumission, on: :collection
      get :en_attente_affectation, on: :collection
      get :en_attente_verification, on: :collection
      get :en_attente_validation, on: :collection
    end

    resources :extinction_allocataires do
      get :en_attente_soumission, on: :collection
      get :en_attente_affectation, on: :collection
      get :en_attente_verification, on: :collection
      get :en_attente_validation, on: :collection
    end

    resources :regularisation_pensions do
      get :toutes_les_demandes, on: :collection
      get :en_attente_soumission, on: :collection
      get :en_attente_instruction, on: :collection
      get :en_attente_valider_directeur, on: :collection
      get :en_attente_verification, on: :collection
      get :en_attente_validation_recap, on: :collection
      get :en_attente_validation_chef_service, on: :collection
      get :en_attente_validation_chef_agence, on: :collection
      get :en_attente_regularisation, on: :collection
      get :en_attente_validation_chef_section, on: :collection
      get :en_attente_validation_inspection, on: :collection
      get :soumettre_all_impayes
      get :annuler_ligne_impaye
      get :valider_all_impayes
      get :valider_ligne_impaye
      get :valider_etat_civil_demandeur
      get :valider_documents
      get :valider_beneficiaire
      get :soumettre
      get :instruire
      patch :retourner_process
      patch :affectation
      patch :affecter_allocataire
      get :valider_recapitulatif
      get :liquidation_valide
      get :recap_valide
      get :valider_chef_service
      get :valider_chef_agence
      get :valider_directeur
      get :valider_chef_section
      get :valider_inspection
      get :dossier_valide
      get :dossier_rejete
      get :regulariser
      patch :rejeter
      get :prendre_en_charge
      get :lettre_notification
      get :new_beneficiary
      post :create_beneficiary
    end

    scope '/regularisation_pensions' do
      get '/regularisation_pension_edit_beneficiary/:id_beneficiary' => 'regularisation_pensions#edit_beneficiary', as: :regularisation_pension_edit_beneficiary
      patch '/regularisation_pension_update_beneficiary/:id_beneficiary' => 'regularisation_pensions#update_beneficiary', as: :regularisation_pension_update_beneficiary
    end

    resources :ordre_paiements

    resources :rentiers do
      get :valider
      get :activer
      patch :rejeter
      get :en_attente_validation, on: :collection
      get :en_attente_activation, on: :collection

    end

    resources :paiements_caisses, only: [:index, :show] do
      get :imprimer_paiement
      post :rendre_impayee
    end
  end

  namespace :employer do
    root to: 'home#index'

    scope '/informations' do
      get '/' => 'informations#index', as: :informations
    end

    resources :services, :paiements, :factures, :moratoires, :representant_legals, :document_immatriculations, :attestations
    resources :declarations do
      get :valider_mouvement
      get :valider_synthese
      get :valider_recapitulatif
      get :soumettre_declaration

      get :ligne_declarations
      #patch :ajouter_ligne
    end

    resources :salarie_immatriculations do
      get 'salarie_immatriculations/import' => 'salarie_immatriculations#my_import'
      collection { post :import }
    end

    resources :immatriculation_private_societes, :immatriculation_associations, :immatriculation_liberales, :immatriculation_gies,
              :immatriculation_cooperatives, :immatriculation_ongs, :immatriculation_projets, :immatriculation_diplomatiques, :immatriculation_maintiens,
              :immatriculation_domestiques, :immatriculation_independants, :immatriculation_individuelles, :immatriculation_structure_prives,
              :immatriculation_structure_publiques do
      patch :update #=> 'home#password_update', as: :password_update
      get :valider_infos_societe
      get :valider_documents
      get :valider_representant
      get :valider_salarie
      get :load_activities
      get :soumettre_demande
      get :download_template
      get :delete_salarie
      collection { post :import }
    end

    resources :effectifs do
      collection { post :import }
    end

    get 'immatriculations/import' => 'immatriculations#my_import'

    get 'effectifs/import' => 'effectifs#my_import'

    get 'missing_ligne_declarations/import' => 'missing_ligne_declarations#my_import'

    resources :immatriculations do
      get :populate_departement_list
      get :download_template
      get :delete_salarie
      get :load_adresse
      get :load_activities
      get :valider_infos_societe
      collection { post :import }

      get ':region/departements', to: 'departements#index', as: 'departements'
    end

    resources :missing_declarations do
      get :valider
      get :delete_document
      get :download_csv
      patch :soumettre

      resources :missing_ligne_declarations do
        collection { post :import }

        patch :update
      end
    end

    resources :missing_ligne_declarations do
      get :retirer
    end

    get :soumission_form
    patch :soumettre
  end

  namespace :allocataire do
    root to: 'home#index'
    resources :allocataire
    resources :paiements
    resources :deces_conjoints
    resources :deces_enfants
    scope '/carrieres' do
      get '/' => 'carrieres#index', as: :carrieres
    end
    resources :update_grappe_familiales
    get '/ajouter_declaration' => 'update_grappe_familiales#ajouter_declaration', as: :ajouter_declaration

    resources :modifier_mode_paiements do
      get :valider_etat_civil_demandeur
      get :valider_documents

    end
    resources :modifier_adresses do
      get :valider_etat_civil_demandeur
      get :valider_documents

    end
    resources :regularisation_pensions
    get '/enfants/active_deces/:id' => 'enfants#active_deces', as: :active_deces_enfant
    get '/conjoints/active_deces/:id' => 'conjoints#active_deces', as: :active_deces
    get '/conjoints/active_divorce/:id' => 'conjoints#active_divorce', as: :active_divorce
    get '/recap_points' => 'home#recap_points', as: :recap_points
    resources :conjoints do
    end

    resources :enfants do
    end
    resources :declaration_deces do
      post :create_document
      get :soumission_form
      patch :soumettre
    end

    resources :dossier_maternites do
      get :valider_etat_civil_demandeur
      get :valider_carriere
      get :valider_documents
      post :create_document

      get :soumission_form
      patch :soumettre

      resources :indemnite_conges_maternites do
        get :soumission_form
        patch :soumettre
      end
    end
  end


  namespace :dynamic_select do
    get ':region/departements', to: 'departements#index', as: 'departements'
  end

  resources :registration_steps

  namespace :caisse do
    root to: 'home#index'

    resources :paiements, only: [:index, :show] do
      post :payer
      get :confirm_payer
      post :decede
      get :mine, on: :collection
      get :imprimer_paiement
    end
  end
end
