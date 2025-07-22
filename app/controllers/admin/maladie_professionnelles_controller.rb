class Admin::MaladieProfessionnellesController < Admin::ApplicationController
  INFO_SALARIE_PAGE = 'information_salarie'.freeze
  INFO_EMPLOYEUR_PAGE = 'information_employeur'.freeze
  INFO_MALADIE_PAGE = 'information_maladie'.freeze
  INFO_DOCUMENT_PAGE = 'information_document'.freeze
  before_action :set_admin_maladie_professionnelle, only: [:show, :edit, :update, :destroy]

  def index
    @q = MaladieProfessionnelle.all.ransack(params[:q])
    @demande_maladie_professionnelles =  @q.result.order('nom_salarie desc').page(params[:page]).per(100)
   
  end

  # GET /admin/arret_travails/1
  def show
    #@mp_document = @demande_maladie_professionnelle.mp_documents.build
    @mp_document = MpDocument.new
  end

  def new
    @demande_maladie_professionnelle = MaladieProfessionnelle.new
  end

   # GET /admin/arret_travails/1/edit
   def edit
    #edit
  end

   def create
    @demande_maladie_professionnelle = MaladieProfessionnelle.new(arret_travail_params)
    @demande_maladie_professionnelle.user_id = current_user.id

    if @demande_maladie_professionnelle.save
      redirect_to [:admin, @demande_maladie_professionnelle], notice: 'Le dossier est créé.'
    else
      render :new
    end
   end

   def update
    case params[:custom_page]
    when INFO_SALARIE_PAGE
      update_salarie_info
    when INFO_EMPLOYEUR_PAGE
      update_employeur_info
    when INFO_MALADIE_PAGE
      update_maladie_info
    when INFO_DOCUMENT_PAGE
      update_document_info
    end

   end

   def delete_document
    @demande_maladie_professionnelle = MaladieProfessionnelle.find(params[:maladie_professionnelle_id])
    @mp_document = MpDocument.find(params[:id])
    respond_to do |format|
      if(@mp_document.delete)
        format.html { redirect_to admin_maladie_professionnelle_path(@demande_maladie_professionnelle), notice: 'Document successfully deleted.' }
      else
        format.html { redirect_to admin_maladie_professionnelle_path(@demande_maladie_professionnelle), warning: 'Document not deleted.' }
      end
    end
   end

   private

   def set_admin_maladie_professionnelle
    @demande_maladie_professionnelle = MaladieProfessionnelle.find(params[:id])
   end

   def allowed_params
    %i( 
      raison_sociale_employeur numero_employeur adresse_employeur boite_postale_employeur email_employeur 
      telephone_employeur fax_employeur activite_principale_entreprise nin_salarie numero_affiliation 
      carnet_accident_travail prenom_salarie nom_salarie date_de_naissance_salarie situation_matrimoniale_salarie 
      nationalite_salarie adresse_domiciliaire_salarie telephone_salarie qualification_professionnelle_salarie 
      date_embauche_salarie anciennete_salarie type_de_contrat_travail_salarie nature_du_travail_au_moment_accident 
      infirmite_anterieure_accident taux_infirmite_anterieure_accident numero_rente_infirmite_anterieure_accident 
      duree_exposition type_de_travaux horaire_travail histoire_professionnelle nature_de_la_maladie produits_utilises 
      condition_travail autre date_premier_constatation_maladie circonstance_apparition_maladie 
      numero_tableau_mp_correspondante salaire_verse_en_totalite_en_mp date_declaration nom_declarant prenom_declarant 
      lieu_declaration info_salarie_valid info_employeur_valid detail_maladie_valid document_valid frais_indemnité_valid 
      user
    )
   end

  def allowed_document_params
    %i(type_document document description maladie_professionnelle_id)
  end

   def allowed_info_salarie_params
    %i( 
      numero_affiliation prenom_salarie nom_salarie date_de_naissance_salarie date_de_naissance_salarie 
      date_de_naissance_salarie qualification_professionnelle_salarie adresse_domiciliaire_salarie nin_salarie 
      carnet_accident_travail situation_matrimoniale_salarie nationalite_salarie telephone_salarie 
      date_embauche_salarie date_embauche_salarie date_embauche_salarie anciennete_salarie type_de_contrat_travail_salarie
    )
   end

   def allowed_info_employeur_params
    %i(  
        raison_sociale_employeur numero_employeur adresse_employeur boite_postale_employeur email_employeur 
        telephone_employeur fax_employeur activite_principale_entreprise
    )
   end
   
   def allowed_info_maladie_params
    %i( 
      nature_du_travail_au_moment_accident infirmite_anterieure_accident taux_infirmite_anterieure_accident 
      numero_rente_infirmite_anterieure_accident duree_exposition type_de_travaux horaire_travail 
      histoire_professionnelle nature_de_la_maladie produits_utilises condition_travail autre 
      date_premier_constatation_maladie  circonstance_apparition_maladie numero_tableau_mp_correspondante 
      salaire_verse_en_totalite_en_mp date_declaration   nom_declarant prenom_declarant lieu_declaration
      )
   end

   def update_salarie_info
    render_infos(@demande_maladie_professionnelle.update(info_salarie_params))
   end

   def update_employeur_info
      render_infos(@demande_maladie_professionnelle.update(info_employeur_params))
   end

  def update_document_info
    @mp_document = MpDocument.new(info_document_params)
    
    if @mp_document.save!
      render_infos(@demande_maladie_professionnelle)
    else
      respond_to do |format|
        format.html { redirect_to admin_maladie_professionnelle_path(@demande_maladie_professionnelle), warning: 'Document not added.' }
      end
    end
  end

   def update_maladie_info
      render_infos(@demande_maladie_professionnelle.update(info_maladie_params))
   end

   def render_infos(infos)
    respond_to do |format|
      if infos
        format.html { redirect_to admin_maladie_professionnelle_path(@demande_maladie_professionnelle), notice: 'Maladie professionnelle was successfully updated.' }
        format.json { render :show, status: :ok, location: admin_maladie_professionnelle_path(@demande_maladie_professionnelle) }
      else
        format.html { render :edit }
        format.json { render json: @demande_maladie_professionnelle.errors, status: :unprocessable_entity }
      end
    end
   end


   def arret_travail_params
    params.require(:maladie_professionnelle).permit(allowed_params)
   end

   def info_salarie_params
    params.require(:maladie_professionnelle).permit(allowed_info_salarie_params)
   end

  def info_document_params
    params.require(:mp_document).permit(allowed_document_params)
  end

   def info_employeur_params
    params.require(:maladie_professionnelle).permit(allowed_info_employeur_params)
   end

   def info_maladie_params
    params.require(:maladie_professionnelle).permit(allowed_info_maladie_params)
   end
end