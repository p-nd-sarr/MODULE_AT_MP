class Admin::PrestationExterieuresController < Admin::ApplicationController

  before_action :set_prestation_exterieure, only: %i[update edit show destroy
   create_document valider_documents valider_informations valider_conjoints
    valider_enfants valider_indemnites valider update_document_form
     create_caf_conjoint create_caf_enfant list_caf_conjoints
      ajouter_indemnites add_numero_caf
      soumettre_etat_famille valider_etat_famille rejeter_etat_famille
       reouvrir_dossier soumettre_droit_liquidation droits_liquidation_details
        valider_par_chef_groupe valider_par_chef_subdivision valider_par_comptable
          reouvrir_conjoints reouvrir_enfants rejeter_dt_liq reouvrir_indemnites generate_etat
          modifier_indemnites liquider_indemnites valider_indemnites_chef_grp
           valider_indemnites_chef_sub valider_indemnites_comptable renouveler_pieces ordre_paiement
            recipisse_depot modifier_dossier valider_x_indemnites_chef_grp valider_x_indemnites_chef_sub
              valider_x_indemnites_chef_cpt liquider_x_indemnites_ges_cpt grappe_familliale historique_dossier
               show_conjoint show_enfant add_conjoint add_enfant edit_conjoint edit_enfant suspendre_dossier
                retourner_indemnite activate_caf_enfant deactivate_caf_enfant]


  def index
    @q = PrestationExterieure.visible_for_admins.ransack(params[:q])
    # @prestation_exterieures = PrestationExterieure.all.page(params[:page]).per(100)
    @prestation_exterieures = @q.result.order('prenom desc').page(params[:page]).per(100)
    @prestation_exterieures_crees = @q.result.with_initialisation_state.order('prenom desc').page(params[:page]).per(100)
    @prestation_exterieures_soumis = @q.result.with_soumission_etat_chef_grp_state.order('prenom desc').page(params[:page]).per(100)
    @prestation_exterieures_valides = @q.result.with_dossier_valide_state.order('prenom desc').page(params[:page]).per(100)
    @prestation_exterieures_rejetes = @q.result.with_dossier_rejete_state.order('prenom desc').page(params[:page]).per(100)
    @prestation_exterieures_suspendus = @q.result.with_dossier_suspendu_state.order('prenom desc').page(params[:page]).per(100)
  end

  def show
    @indemnites_prestation = IndemnitesPrestationExterieure.new
    @document_prestation_exterieure = DocumentPrestationExterieure.new
    set_home_data
  end

  def edit
    @countries = Admin::Country.all.where(est_pays_caf: true)
  end

  # GET /prestation_exterieures/new
  def new
    @prestation_exterieure = PrestationExterieure.new
    @countries = Admin::Country.all.where(est_pays_caf: true)
  end

  def create
    @prestation_exterieure = PrestationExterieure.new(prestation_exterieure_params)
    @prestation_exterieure.etat = :creation
    @prestation_exterieure.ajoute_par = current_user

    exists_pres = PrestationExterieure.where(nin_salarie: @prestation_exterieure.nin_salarie).last
    if !exists_pres.nil? && exists_pres.created_at.year == Time.now.year
      flash[:error] = "Ce salarié a déjà un dossier de prestation CAF en cours."
      redirect_to admin_prestation_exterieures_path
      return
    end

    if @prestation_exterieure.save
      @prestation_exterieure.information_valid!(false)
      @new_item = PrestationExterieure.last
      redirect_to admin_prestation_exterieure_path(@new_item.id), notice: 'Le dossier a été créé avec succès.'
    else
      @query = 'new'
      render :new
    end
  end

  def update
    if @prestation_exterieure.update(prestation_exterieure_params)
      redirect_to admin_prestation_exterieure_path(@prestation_exterieure.id), notice: 'Le dossier a été modifié avec succès.'
    else
      @query = 'edit'
      render :edit
    end
  end

  def destroy
    if @prestation_exterieure.destroy
      redirect_to admin_prestation_exterieures_path, notice: 'Le dossier a été supprimé avec succès.'
    end
  end

  def create_caf_conjoint
    @caf_conjoint = CafConjoint.new(caf_conjoint_params)
    @caf_conjoint.ajoute_par = current_user
    if @caf_conjoint.save
      @prestation_exterieure.conjoint_valid!(false)
      @item = CafConjoint.last
      redirect_to admin_prestation_exterieure_show_conjoint_path(@item.prestation_exterieure_id, @caf_conjoint.id), notice: 'Le conjoint a été ajouté avec succès.'
    else
      @conjoint = @caf_conjoint
      render :add_conjoint
    end
  end

  def update_caf_conjoint
    @caf_conjoint = CafConjoint.find(params[:conjoint_id])

    if @caf_conjoint.update(caf_conjoint_params)
      redirect_to admin_prestation_exterieure_show_conjoint_path(@caf_conjoint.prestation_exterieure_id, @caf_conjoint), notice: 'Le conjoint a été modifié avec succès.'
    else
      @conjoint = @caf_conjoint
      @prestation_exterieure = @conjoint.prestation_exterieure
      render :edit_conjoint
    end
  end

  def delete_caf_conjoint
    @caf_conjoint = CafConjoint.find(params[:conjoint_id])

    if @caf_conjoint.destroy
      redirect_to admin_prestation_exterieure_grappe_familliale_path(@caf_conjoint.prestation_exterieure_id), notice: 'Le conjoint a été supprimé avec succès.'
    else
      flash[:error] = @caf_conjoint.errors.full_messages
      redirect_to admin_prestation_exterieure_grappe_familliale_path(@caf_conjoint.prestation_exterieure_id)
    end
  end

  def create_caf_enfant
    @caf_enfant = CafEnfant.new(caf_enfant_params)
    @caf_enfant.ajoute_par = current_user
    @caf_enfant.prestation_exterieure = @prestation_exterieure

    if @caf_enfant.save
      @prestation_exterieure.enfant_valid!(false)
      redirect_to admin_prestation_exterieure_show_enfant_path(@prestation_exterieure.id, @caf_enfant.id), notice: "l'enfant a été ajouté avec succès."
    else
      @enfant = @caf_enfant
      @conjoints = CafConjoint.where(prestation_exterieure_id: @prestation_exterieure[:id])
      render :add_enfant
    end
  end

  def update_caf_enfant
    @caf_enfant = CafEnfant.find(params[:enfant_id])

    if @caf_enfant.update(caf_enfant_params)
      redirect_to admin_prestation_exterieure_show_enfant_path(@caf_enfant.caf_conjoint.prestation_exterieure_id, @caf_enfant), notice: "L'enfant a été modifié avec succès."
    else
      @enfant = @caf_enfant
      @prestation_exterieure = @enfant.prestation_exterieure
      @conjoints = CafConjoint.where(prestation_exterieure_id: @prestation_exterieure[:id])
      render :edit_enfant
    end
  end

  def delete_caf_enfant
    @caf_enfant = CafEnfant.find(params[:enfant_id])

    if @caf_enfant.destroy
      redirect_to admin_prestation_exterieure_grappe_familliale_path(@caf_enfant.prestation_exterieure_id), notice: "L'enfant a été supprimé avec succès."
    else
      flash[:error] = @caf_enfant.errors.full_messages
      redirect_to admin_prestation_exterieure_grappe_familliale_path(@caf_enfant.prestation_exterieure_id)
    end
  end


  def create_document
    @document_prestation_exterieure = DocumentPrestationExterieure.new(document_prestation_exterieure_params)
    @document_prestation_exterieure.prestation_exterieure = @prestation_exterieure

    if @document_prestation_exterieure.save
      @prestation_exterieure.document_valid!(false)
      redirect_to admin_prestation_exterieure_path(params[:prestation_exterieure_id]), notice: 'Le document est ajouté.'
    else
      flash[:error] = "Une erreur est survenue lors de l'ajout du document."
      redirect_to admin_prestation_exterieure_path(params[:prestation_exterieure_id])
    end
  end

  def valider_documents
    @prestation_exterieure.document_valid!
    redirect_to admin_prestation_exterieure_path(params[:prestation_exterieure_id]), notice: 'Tous les documents ont été validés.'
  end

  def valider_informations
    @prestation_exterieure.information_valid!
    redirect_to admin_prestation_exterieure_path(params[:prestation_exterieure_id]), notice: 'Les informations sur le salarié ont été validés.'
  end

  def valider_conjoints
    @prestation_exterieure.conjoint_valid!
    redirect_to admin_prestation_exterieure_path(params[:prestation_exterieure_id]), notice: 'Les informations sur les conjoints ont été validés.'
  end

  def valider_enfants
    @prestation_exterieure.enfant_valid!
    redirect_to admin_prestation_exterieure_path(params[:prestation_exterieure_id]), notice: 'Les informations sur les enfants ont été validés.'
  end

  def valider_indemnites
    @prestation_exterieure.indemnite_valid!
    redirect_to admin_prestation_exterieure_path(params[:prestation_exterieure_id]), notice: 'Les informations sur les enfants ont été validés.'
  end

  def update_document
    @document_prestation_exterieure = DocumentPrestationExterieure.find(params[:document_prestation_exterieure_id])
    @document_prestation_exterieure.update(document_prestation_exterieure_params)
    redirect_to admin_prestation_exterieure_path(params[:prestation_exterieure_id]), notice: 'Le document à été modifié avec succès'
  end

  def update_document_form
    @document_prestation_exterieure = DocumentPrestationExterieure.find(params[:document_prestation_exterieure_id])
  end

  def destroy_document
    @document_prestation_exterieure = DocumentPrestationExterieure.find(params[:document_prestation_exterieure_id])
    @document_prestation_exterieure.destroy
    redirect_to admin_prestation_exterieure_path(params[:prestation_exterieure_id]), notice: 'Le document à été supprimé avec succès'
  end

  def valider
    @prestation_exterieure.etat = :valide
    if @prestation_exterieure.save
      redirect_to admin_prestation_exterieure_path(params[:prestation_exterieure_id]), notice: 'La demande de prestation exterieure CAF a été validé avec succès'
    else
      flash[:error] = "Une erreur est survenue lors de la validation."
      redirect_to admin_prestation_exterieure_path(params[:prestation_exterieure_id])
    end

  end

  def reouvrir_conjoints
    @prestation_exterieure.conjoint_invalid!
    redirect_to admin_prestation_exterieure_path(params[:prestation_exterieure_id]), notice: 'La section conjoints a été réouverte avec succès.'
  end

  def reouvrir_enfants
    @prestation_exterieure.enfant_invalid!
    redirect_to admin_prestation_exterieure_path(params[:prestation_exterieure_id]), notice: 'La section enfants a été réouverte avec succès.'
  end


  def reouvrir_indemnites
    @prestation_exterieure.indemnites_invalid!
    redirect_to admin_prestation_exterieure_path(params[:prestation_exterieure_id]), notice: 'La section indemnités a été réouverte avec succès.'
  end

  def generate_etat
    @conjoints = CafConjoint.where(prestation_exterieure_id: @prestation_exterieure[:id]).page(params[:page]).per(100)
    @enfants = CafEnfant.joins(:caf_conjoint).where(:caf_conjoints => {:prestation_exterieure_id => @prestation_exterieure[:id]}).page(params[:page]).per(100)
    respond_to do |format|
      format.html
      format.pdf do
        generated_pdf = render_to_string pdf: "Récépissé demande de prestation exterieure CAF No. #{@prestation_exterieure.numero_dossier}",
                                         page_size: 'A4',
                                         template: "admin/prestation_exterieures/generated_etat.html.erb",
                                         layout: "pdf.html",
                                         orientation: "Landscape",
                                         lowquality: true,
                                         zoom: 1,
                                         pi: 75
        pdf = CombinePDF.new
        pdf << CombinePDF.parse(generated_pdf)
        pdf_first_page = pdf.pages[0]
        mediabox = pdf_first_page[:CropBox] || pdf_first_page[:MediaBox]
        title_page = CombinePDF.create_page mediabox
        full_name = 'Les pieces jointes du salarie ' + @prestation_exterieure.prenom + ' ' + @prestation_exterieure.nom
        title_page.textbox full_name, font_color: [0.8, 0, 0], font_size: :fit_text, box_color: [1, 0.8, 0.8], opacity: 1
        pdf << title_page
        @prestation_exterieure.documents.each do |att|
          if att.document.attached? && att.document.present?
            begin
              data = att.document.download
              pdf << CombinePDF.parse(data)
            rescue => e
              Rails.logger.error("Failed to process document : #{e.message}")
            end
          else
            Rails.logger.warn("No document attached for #{@prestation_exterieure.prenom} #{@prestation_exterieure.nom}")
          end
        end

        @conjoints.each do |conjoint|
          title_page = CombinePDF.create_page mediabox
          full_name = 'Les pieces jointes du conjoint ' + conjoint.prenom + ' ' + conjoint.nom
          title_page.textbox full_name, font_color: [0.8, 0, 0], font_size: :fit_text, box_color: [1, 0.8, 0.8], opacity: 1
          pdf << title_page

          # Handle piece_identite
          if conjoint.piece_identite.attached?
            begin
              pi = conjoint.piece_identite.download
              pdf << CombinePDF.parse(pi)
            rescue => e
              Rails.logger.warn("Skipping piece_identite for #{conjoint.prenom} #{conjoint.nom}: #{e.message}")
            end
          else
            Rails.logger.warn("No piece_identite attached for #{conjoint.prenom} #{conjoint.nom}")
          end

          # Handle certificat_mariage
          if conjoint.certificat_mariage.attached?
            begin
              cm = conjoint.certificat_mariage.download
              pdf << CombinePDF.parse(cm)
            rescue => e
              Rails.logger.warn("Skipping certificat_mariage for #{conjoint.prenom} #{conjoint.nom}: #{e.message}")
            end
          else
            Rails.logger.warn("No certificat_mariage attached for #{conjoint.prenom} #{conjoint.nom}")
          end
        end

        @enfants.each do |enfant|
          title_page = CombinePDF.create_page mediabox
          full_name = "Les pieces jointes de l'enfant " + enfant.prenom + ' ' + enfant.nom
          title_page.textbox full_name, font_color: [0.8, 0, 0], font_size: :fit_text, box_color: [1, 0.8, 0.8], opacity: 1
          pdf << title_page

          enfant.documents.each do |att|
            if att.document.attached? && att.document.present?
              begin
                data = att.document.download
                pdf << CombinePDF.parse(data)
              rescue => e
                Rails.logger.error("Failed to process document for #{enfant.prenom} #{enfant.nom}: #{e.message}")
              end
            else
              Rails.logger.warn("No document attached for #{enfant.prenom} #{enfant.nom}")
            end
          end
        end

=begin
        a4_size = [0, 0, 595, 842]
        pdf.pages.each {|p| p.resize a4_size}
=end
        send_data pdf.to_pdf, filename: "etat_famille.pdf", type: "application/pdf"
      end
    end
  end


  def list_caf_conjoints
    @conjoints = CafConjoint.where(prestation_exterieure_id: @prestation_exterieure[:id]).page(params[:page]).per(100)
  end


  def ajouter_indemnites
    @indemnites_prestation = IndemnitesPrestationExterieure.new(indemnites_prestation_exterieure_params)
    @indemnites_prestation.prestation_exterieure = @prestation_exterieure

    if @indemnites_prestation.save
      redirect_to admin_prestation_exterieure_path(@prestation_exterieure.id), notice: 'Les indemnites ont été ajoutées avec succès.'
    else
      set_home_data
      render :show
    end
  end

  def liquider_indemnites
    @indemnites_prestation = IndemnitesPrestationExterieure.find(params[:indemnites_id])

    if !@indemnites_prestation.has_bareme?
      flash[:error] = "Veuillez renseigner un barème pour cette période."
      redirect_to admin_prestation_exterieure_path(@prestation_exterieure.id)
      return
    end

    if @indemnites_prestation.eligible_childreen == 0
      flash[:error] = "Aucun enfant eligible pour cette période."
      redirect_to admin_prestation_exterieure_path(@prestation_exterieure.id)
      return
    end

    if @indemnites_prestation.init?
      @indemnites_prestation.montant = @indemnites_prestation.get_solde
      @indemnites_prestation.liquide_par = current_user
      @indemnites_prestation.date_liquidation = DateTime.now
      @indemnites_prestation.retourne_par = nil
      @indemnites_prestation.date_retour = nil
      @indemnites_prestation.motif_retour = nil
      @indemnites_prestation.liquider_dt!
    end

    if @indemnites_prestation.save
      redirect_to admin_prestation_exterieure_path(@prestation_exterieure.id), notice: 'Les indemnites ont été liquidées avec succès.'
    else
      set_home_data
      render :show
    end
  end

  def liquider_x_indemnites_ges_cpt
    if @prestation_exterieure.has_initialized_indemnities?
      PrestationExterieure.initialized_indemnities(@prestation_exterieure.id).each do |indemnite|
        if indemnite.init? and indemnite.has_bareme? and indemnite.eligible_childreen > 0
          indemnite.montant = indemnite.get_solde
          indemnite.liquide_par = current_user
          indemnite.date_liquidation = DateTime.now
          indemnite.retourne_par = nil
          indemnite.date_retour = nil
          indemnite.motif_retour = nil
          indemnite.liquider_dt!
          indemnite.save
        end
      end
    end

    redirect_to admin_prestation_exterieure_path(@prestation_exterieure.id), notice: 'Les indemnites ont été liquidées avec succès.'

  end

  def modifier_indemnites
    @indemnites_prestation = IndemnitesPrestationExterieure.find(params[:indemnites_id])
    if @indemnites_prestation.update(indemnites_prestation_exterieure_params)
      redirect_to admin_prestation_exterieure_path(@prestation_exterieure.id), notice: 'Les indemnites ont été midifiées avec succès.'
    else
      flash[:error] = @indemnites_prestation.errors.full_messages
      redirect_to admin_prestation_exterieure_path(@prestation_exterieure.id)
    end
  end

  def update_indemnites

  end


  def destroy_indemnites
    @indemnites_prestation = IndemnitesPrestationExterieure.find(params[:indemnites_id])
    @indemnites_prestation.destroy
    redirect_to admin_prestation_exterieure_path(params[:prestation_exterieure_id]), notice: "L'enfant à été supprimé avec"
  end

  def add_numero_caf
    @prestation_exterieure = PrestationExterieure.find(params[:prestation_exterieure_id])
    @prestation_exterieure.update(prestation_exterieure_params)
    redirect_to admin_prestation_exterieure_path(params[:prestation_exterieure_id]), notice: 'Le numero à été ajouté avec succès'
  end

  def add_caisse_caf
    @prestation_exterieure = PrestationExterieure.find(params[:prestation_exterieure_id])
    @prestation_exterieure.update(prestation_exterieure_params)
    redirect_to admin_prestation_exterieure_path(params[:prestation_exterieure_id]), notice: 'La caisse CAF à été ajoutée avec succès'
  end


  def etats_famille
    @prestation_exterieures_soumis = PrestationExterieure.where(workflow_state: :soumission_etat_chef_grp).order('prenom desc').page(params[:page]).per(100)
    @prestation_exterieures_valides = PrestationExterieure.where(workflow_state: :dossier_valide).order('prenom desc').page(params[:page]).per(100)
    @prestation_exterieures = PrestationExterieure.where(workflow_state: :soumission_etat_chef_grp).order('prenom desc').page(params[:page]).per(100)
  end

  def droits_liquidation
    if current_user.chef_groupe_caf?
      @prestation_exterieures = PrestationExterieure.joins(:indemnites_prestation_exterieures).where(indemnites_prestation_exterieures: {workflow_state_dt: :liquidation}).distinct.order('prenom desc').page(params[:page]).per(100)
      @prestation_exterieures_all = PrestationExterieure.joins(:indemnites_prestation_exterieures).where(indemnites_prestation_exterieures: { workflow_state_dt: [:validation_dt_chef_grp, :validation_dt_chef_sub, :droit_valide, :droit_rejete] }).distinct.order('prenom desc').page(params[:page]).per(100)
    elsif current_user.chef_subdivision_caf?
      @prestation_exterieures = PrestationExterieure.joins(:indemnites_prestation_exterieures).where(indemnites_prestation_exterieures: {workflow_state_dt: :validation_dt_chef_grp}).distinct.order('prenom desc').page(params[:page]).per(100)
      @prestation_exterieures_all = PrestationExterieure.joins(:indemnites_prestation_exterieures).where(indemnites_prestation_exterieures: { workflow_state_dt: [:validation_dt_chef_sub, :droit_valide, :droit_rejete] }).distinct.order('prenom desc').page(params[:page]).per(100)
    elsif current_user.comptable?
      @prestation_exterieures = PrestationExterieure.joins(:indemnites_prestation_exterieures).where(indemnites_prestation_exterieures: {workflow_state_dt: :validation_dt_chef_sub}).distinct.order('prenom desc').page(params[:page]).per(100)
      @prestation_exterieures_all = PrestationExterieure.joins(:indemnites_prestation_exterieures).where(indemnites_prestation_exterieures: { workflow_state_dt: [:validation_dt_chef_sub, :droit_valide, :droit_rejete] }).distinct.order('prenom desc').page(params[:page]).per(100)
    end
  end

  def droits_liquidation_details
    @conjoints = CafConjoint.where(prestation_exterieure_id: @prestation_exterieure[:id])
    # End historiques
    @payment_orders = @prestation_exterieure.ordre_paiements.includes(:compta_transactions).order("created_at DESC").page(params[:page]).per(10)
    # indemnities by user connected
    @indemnities = if current_user.gestionnaire_compte_allocataire?
                     @prestation_exterieure.indemnites_prestation_exterieures
                   elsif current_user.chef_subdivision_caf?
                     @prestation_exterieure.indemnites_prestation_exterieures.execute_by_chef_subdivision_caf
                   elsif current_user.chef_groupe_caf?
                     @prestation_exterieure.indemnites_prestation_exterieures.execute_by_chef_groupe_caf
                   elsif current_user.comptable?
                     @prestation_exterieure.indemnites_prestation_exterieures.execute_by_comptable
                   else
                     @prestation_exterieure.indemnites_prestation_exterieures
                   end
  end

  def soumettre_etat_famille
    if @prestation_exterieure.initialisation?
      @prestation_exterieure.soumettre_etf!
      @prestation_exterieure.soumis_etf_par = current_user
      @prestation_exterieure.date_soumission_etf = DateTime.now
    end

    if @prestation_exterieure.save
      redirect_to admin_prestation_exterieure_generate_etat_path(@prestation_exterieure), notice: "L'état de famille a été soumis avec succès"
    else
      flash[:error] = "Une erreur est survenue lors de la soumission."
      redirect_to admin_prestation_exterieure_generate_etat_path(@prestation_exterieure)
    end

  end


  def valider_etat_famille
    if @prestation_exterieure.soumission_etat_chef_grp?
      @prestation_exterieure.est_dossier_valide!
      @prestation_exterieure.etat_famille_valid = true
      @prestation_exterieure.valide_etf_par = current_user
      @prestation_exterieure.date_validation_etf = DateTime.now
    end

    if @prestation_exterieure.save
      redirect_to admin_prestation_exterieure_generate_etat_path(@prestation_exterieure), notice: "L'état de famille a été validé avec succès"
    else
      flash[:error] = "Une erreur est survenue lors de la validation."
      redirect_to admin_prestation_exterieure_generate_etat_path(@prestation_exterieure)
    end
  end

  def rejeter_etat_famille
    if @prestation_exterieure.soumission_etat_chef_grp?
      @prestation_exterieure.rejeter_etat_famille!
      @prestation_exterieure.date_rejet_etf = Date.today
      @prestation_exterieure.update(prestation_exterieure_params)
      @prestation_exterieure.etat_famille_valid = false
    end

    if @prestation_exterieure.save
      @prestation_exterieure.soumis_etf_par = nil
      @prestation_exterieure.date_soumission_etf = nil
      redirect_to admin_prestation_exterieure_generate_etat_path(@prestation_exterieure), notice: "L'état de famille a été rejeté avec succès"
    else
      flash[:error] = "Une erreur est survenue."
      redirect_to admin_prestation_exterieure_generate_etat_path(@prestation_exterieure)
    end
  end

  def reouvrir_dossier
    @prestation_exterieure.reouvrir_dossier!
    redirect_to admin_prestation_exterieure_path(@prestation_exterieure.id),
                notice: 'Le dossier a été réouvert à noouveau'
  end

  def en_attente_allocation
    @q = PrestationExterieure.visible_for_admins.ransack(params[:q])
    @prestation_en_attente_alloc = @q.result.with_dossier_valide_state.order('prenom desc').page(params[:page]).per(100)
  end

  def en_attente_paiement
    @q = PrestationExterieure.joins(:indemnites_prestation_exterieures).where(indemnites_prestation_exterieures: { workflow_state_dt: :droit_valide }).distinct.ransack(params[:q])
    @prestation_en_attente_paiement = @q.result.with_dossier_valide_state.order('prenom desc').page(params[:page]).per(100)
  end

  def retourner_indemnite
    @indemnity = IndemnitesPrestationExterieure.find(params[:indemnites_id])
    if current_user.chef_groupe_caf?
      @indemnity.workflow_state_dt = :init
    elsif current_user.chef_subdivision_caf?
      @indemnity.workflow_state_dt = :liquidation
    elsif current_user.comptable?
      @indemnity.workflow_state_dt = :validation_dt_chef_grp
    end
    if @indemnity.update(indemnites_prestation_exterieure_params.merge(retourne_par: current_user,
                                                                       date_retour: DateTime.now))
      redirect_to admin_droits_liquidation_details_path(@prestation_exterieure), notice: 'Indemnité retournée avec succès !.'
    else
      flash[:error] = 'Une erreur est survenue lors du traitement'
      redirect_to admin_droits_liquidation_details_path(@prestation_exterieure)
    end
  end

  def soumettre_droit_liquidation
    if @prestation_exterieure.validation_etat_chef_grp?
      @prestation_exterieure.est_soumis_dt_liq!
      @prestation_exterieure.soumis_liq_par = current_user
      @prestation_exterieure.date_soumission_liq = DateTime.now
    end

    if @prestation_exterieure.save
      redirect_to admin_prestation_exterieure_path(@prestation_exterieure.id), notice: "Les droits de liquidation ont été soumis avec succès"
    else
      flash[:error] = "Une erreur est survenue lors de la soumission."
      redirect_to admin_prestation_exterieure_path(@prestation_exterieure.id)
    end
  end

  def valider_indemnites_chef_grp
    @indemnites_prestation = IndemnitesPrestationExterieure.find(params[:indemnites_id])

    if @indemnites_prestation.liquidation?
      @indemnites_prestation.est_dt_valide_par_chef_grp!
      @indemnites_prestation.valide_chef_grp_par = current_user
      @indemnites_prestation.date_validation_chef_grp = DateTime.now
      @indemnites_prestation.retourne_par = nil
      @indemnites_prestation.date_retour = nil
      @indemnites_prestation.motif_retour = nil
    end

    if @indemnites_prestation.save
      redirect_to admin_droits_liquidation_details_path(@prestation_exterieure.id), notice: "Les droits de liquidation ont été validés avec succès"
    else
      flash[:error] = "Une erreur est survenue lors de la validation"
      redirect_to admin_droits_liquidation_details_path(@prestation_exterieure.id)
    end
  end

  def valider_x_indemnites_chef_grp
    if @prestation_exterieure.has_liquidated_indemnites?
      PrestationExterieure.liquidated_indemnites(@prestation_exterieure.id).each do |indemnite|
        if indemnite.liquidation?
          indemnite.est_dt_valide_par_chef_grp!
          indemnite.valide_chef_grp_par = current_user
          indemnite.date_validation_chef_grp = DateTime.now
          indemnite.retourne_par = nil
          indemnite.date_retour = nil
          indemnite.motif_retour = nil
          indemnite.save
        end
      end
    end

    redirect_to admin_droits_liquidation_details_path(@prestation_exterieure.id), notice: "Opération effectuée avec succès"

  end

  def valider_x_indemnites_chef_sub
    if @prestation_exterieure.has_validated_chef_grp_indemnites?
      PrestationExterieure.validated_chef_grp_indemnites(@prestation_exterieure.id).each do |indemnite|
        if indemnite.validation_dt_chef_grp?
          indemnite.est_dt_valide_par_chef_sub!
          indemnite.valide_chef_sub_par = current_user
          indemnite.date_validation_chef_sub = DateTime.now
          indemnite.retourne_par = nil
          indemnite.date_retour = nil
          indemnite.motif_retour = nil
          indemnite.save
        end
      end
    end
    redirect_to admin_droits_liquidation_details_path(@prestation_exterieure.id), notice: "Opération effectuée avec succès"
  end

  def valider_x_indemnites_chef_cpt
    ValiderPaiementsPrestationExterieureJob.perform_now(@prestation_exterieure, current_user)

    flash[:notice] = "Génération de l'ordre de paiement en cours ..."

    redirect_to admin_droits_liquidation_details_path(@prestation_exterieure)
  end

  # def valider_x_indemnites_chef_cpt
  #   if @prestation_exterieure.has_validated_chef_sub_indemnites?
  #     PrestationExterieure.validated_chef_sub_indemnites(@prestation_exterieure.id).each do |indemnite|
  #       if indemnite.validation_dt_chef_sub?
  #         indemnite.est_dt_valide!
  #         indemnite.valide_cpt_par = current_user
  #         indemnite.date_validation_cpt = DateTime.now
  #         indemnite.save
  #       end
  #     end
  #   end
  #   redirect_to admin_droits_liquidation_details_path(@prestation_exterieure.id), notice: "Opération effectuée avec succès"
  # end

  def valider_indemnites_chef_sub
    @indemnites_prestation = IndemnitesPrestationExterieure.find(params[:indemnites_id])

    if @indemnites_prestation.validation_dt_chef_grp?
      @indemnites_prestation.est_dt_valide_par_chef_sub!
      @indemnites_prestation.valide_chef_sub_par = current_user
      @indemnites_prestation.date_validation_chef_sub = DateTime.now
      @indemnites_prestation.retourne_par = nil
      @indemnites_prestation.date_retour = nil
      @indemnites_prestation.motif_retour = nil
    end

    if @indemnites_prestation.save
      redirect_to admin_droits_liquidation_details_path(@prestation_exterieure.id), notice: "Les droits de liquidation ont été validés avec succès"
    else
      flash[:error] = "Une erreur est survenue lors de la validation"
      redirect_to admin_droits_liquidation_details_path(@prestation_exterieure.id)
    end
  end

  def valider_indemnites_comptable
    @indemnites_prestation = IndemnitesPrestationExterieure.find(params[:indemnites_id])

    if @indemnites_prestation.validation_dt_chef_sub?
      @indemnites_prestation.est_dt_valide!
      @indemnites_prestation.valide_cpt_par = current_user
      @indemnites_prestation.date_validation_cpt = DateTime.now
    end

    if @indemnites_prestation.save
      redirect_to admin_droits_liquidation_details_path(@prestation_exterieure.id), notice: "Les droits de liquidation ont été validés avec succès"
    else
      flash[:error] = "Une erreur est survenue lors de la validation"
      redirect_to admin_droits_liquidation_details_path(@prestation_exterieure.id)
    end
  end

  def valider_par_chef_groupe
    if @prestation_exterieure.soumission_dt_liq_chef_grp?
      @prestation_exterieure.est_valide_dt_liq_chef_grp!
      @prestation_exterieure.valide_liq_par_chef_grp = current_user
      @prestation_exterieure.date_validation_liq_chef_grp = DateTime.now
    end

    if @prestation_exterieure.save
      redirect_to admin_droits_liquidation_details_path(@prestation_exterieure.id), notice: "Les droits de liquidation ont été validés avec succès"
    else
      flash[:error] = "Une erreur est survenue lors de la validation"
      redirect_to admin_droits_liquidation_details_path(@prestation_exterieure.id)
    end
  end

  def valider_par_chef_subdivision
    if @prestation_exterieure.validation_dt_liq_chef_grp?
      @prestation_exterieure.est_valide_dt_liq_chef_sub!
      @prestation_exterieure.valide_liq_par_chef_sub = current_user
      @prestation_exterieure.date_validation_liq_chef_sub = DateTime.now
    end

    if @prestation_exterieure.save
      redirect_to admin_droits_liquidation_details_path(@prestation_exterieure.id), notice: "Les droits de liquidation ont été validés avec succès"
    else
      flash[:error] = "Une erreur est survenue lors de la validation"
      redirect_to admin_droits_liquidation_details_path(@prestation_exterieure.id)
    end
  end


  def valider_par_comptable
    if @prestation_exterieure.validation_dt_liq_chef_sub?
      @prestation_exterieure.est_validation_comptable!
      @prestation_exterieure.valide_liq_comptable = current_user
      @prestation_exterieure.date_validation_liq_comptable = DateTime.now
    end

    if @prestation_exterieure.save
      redirect_to admin_droits_liquidation_details_path(@prestation_exterieure.id), notice: "Les droits de liquidation ont été validés avec succès"
    else
      flash[:error] = "Une erreur est survenue lors de la validation"
      redirect_to admin_droits_liquidation_details_path(@prestation_exterieure.id)
    end
  end


  def rejeter_dt_liq
    if @prestation_exterieure.soumission_dt_liq_chef_grp?
      @prestation_exterieure.retour_validation_etat_chef_grp!
    end

    if @prestation_exterieure.validation_dt_liq_chef_grp?
      @prestation_exterieure.retour_validation_etat_chef_grp!
    end

    if @prestation_exterieure.validation_dt_liq_chef_sub?
      @prestation_exterieure.retour_validation_etat_chef_grp!
    end

    @prestation_exterieure.update(prestation_exterieure_params)

    if @prestation_exterieure.save
      redirect_to admin_droits_liquidation_path, notice: "Les droits de liquidation ont été rejeté avec succès"
    else
      flash[:error] = "Une erreur est survenue."
      redirect_to admin_droits_liquidation_path
    end
  end


  def renouveler_pieces
    @enfants = CafEnfant.joins(caf_conjoint: :prestation_exterieure).where(prestation_exterieures: {id: @prestation_exterieure.id})
  end

  def replace_extrait
    @caf_enfant = CafEnfant.find(params[:prestation_exterieure_id])
    @conjoint = @caf_enfant.caf_conjoint
    @prestation_exterieure = PrestationExterieure.find(@conjoint.prestation_exterieure_id)

    if @caf_enfant.update(caf_enfant_params)
      if !@prestation_exterieure.require_pieces_change?
        if @prestation_exterieure.dossier_suspendu?
          @prestation_exterieure.retour_dossier_valide!
        end
        redirect_to admin_prestation_exterieure_path(@prestation_exterieure), notice: "Tous les documents ont été renouvelés avec sucès."
      else
        redirect_to admin_prestation_exterieure_renouveler_pieces_path(@prestation_exterieure), notice: "L'enfant a été modifié avec succès."
      end
    else
      flash[:error] = @caf_enfant.errors.full_messages
      redirect_to admin_prestation_exterieure_renouveler_pieces_path(@prestation_exterieure)
    end
  end



  def ordre_paiement
    @conjoint = CafConjoint.find(params[:conjoint_id])
    @beneficiary = CafConjoint.where(prestation_exterieure_id: @prestation_exterieure[:id], is_beneficiary: true).first

    @d_debut = params[:d_debut]
    @d_fin = params[:d_fin]

    @indemnites_prestation = IndemnitesPrestationExterieure.where(prestation_exterieure_id: @prestation_exterieure.id, date_debut: @d_debut, date_fin: @d_fin).first

    respond_to do |format|
      format.html
      format.pdf do
        render pdf: "Ordre de paiement No. #{@prestation_exterieure.numero_dossier}",
               page_size: 'A4',
               template: "admin/prestation_exterieures/ordre_paiement.html.erb",
               layout: "pdf.html",
               orientation: "Landscape",
                                         lowquality: true,
                                         zoom: 1,
                                         pi: 75
      end
    end
  end


  def recipisse_depot
    respond_to do |format|
      format.html
      format.pdf do
        render pdf: "Récipissé de dépot No. #{@prestation_exterieure.numero_dossier}",
               page_size: 'A4',
               template: "admin/prestation_exterieures/recipisse_depot.html.erb",
               layout: "pdf.html",
               orientation: "Landscape",
               lowquality: true,
               zoom: 1,
               pi: 75
      end
    end
  end

  def modifier_dossier

  end

  def grappe_familliale
    @q_conj = CafConjoint.where(prestation_exterieure_id: @prestation_exterieure[:id]).ransack(params[:q])
    @conjoints = @q_conj.result.order('prenom asc').page(params[:page]).per(100)
    @q_enf = CafEnfant.joins(:caf_conjoint).where(caf_conjoints: { prestation_exterieure_id: @prestation_exterieure[:id] }).ransack(params[:q])
    @enfants = @q_enf.result.order('prenom asc').page(params[:page]).per(100)
  end

  def historique_dossier
    @droits_liquidations = @prestation_exterieure.indemnites_prestation_exterieures.page(params[:page]).per(100)
  end

  def show_conjoint
    @conjoint = CafConjoint.find(params[:conjoint_id])
  end

  def show_enfant
    @enfant = CafEnfant.find(params[:enfant_id])
  end

  def add_conjoint
    @conjoint = CafConjoint.new(prestation_exterieure_id: @prestation_exterieure[:id])
  end

  def add_enfant
    @conjoints = CafConjoint.where(prestation_exterieure_id: @prestation_exterieure[:id])
    @enfant = CafEnfant.new
  end

  def edit_conjoint
    @conjoint = CafConjoint.find(params[:conjoint_id])
  end

  def edit_enfant
    @conjoints = CafConjoint.where(prestation_exterieure_id: @prestation_exterieure[:id])
    @enfant = CafEnfant.find(params[:enfant_id])
  end

  def suspendre_dossier
    if @prestation_exterieure.dossier_valide?
      @prestation_exterieure.est_dossier_suspendu!
      @prestation_exterieure.suspendu_par = current_user
      @prestation_exterieure.date_suspension = DateTime.now
    end

    if @prestation_exterieure.save
      redirect_to [:admin, @prestation_exterieure], notice: 'Le dossier est suspendu !'
    else
      flash[:notice] = 'Une erreur est survenue', @prestation_exterieure.errors.full_messages
      redirect_to [:admin, @prestation_exterieure]
    end
  end

  def activate_caf_enfant
    @caf_enfant = CafEnfant.find(params[:enfant_id])
    @caf_enfant.activate!
    redirect_to admin_prestation_exterieure_path(@prestation_exterieure), notice: "L'enfant a été activer avec succès."
  end

  def deactivate_caf_enfant
    @caf_enfant = CafEnfant.find(params[:enfant_id])
    @caf_enfant.deactivate!
    redirect_to admin_prestation_exterieure_path(@prestation_exterieure), notice: "L'enfant a été désactiver avec succès."
  end

  def add_beneficiary
    @caf_conjoint = CafConjoint.find(params[:prestation_exterieure_id])
    @caf_conjoint.is_beneficiary!
    redirect_to admin_prestation_exterieure_path(@caf_conjoint.prestation_exterieure_id), notice: 'Le conjoint a été choisi en tant bénéficiaire avec succès.'
  end

  def remove_beneficiary
    @caf_conjoint = CafConjoint.find(params[:prestation_exterieure_id])
    @caf_conjoint.is_not_beneficiary_anymore!
    redirect_to admin_prestation_exterieure_path(@caf_conjoint.prestation_exterieure_id), notice: 'Le conjoint a été choisi en tant bénéficiaire avec succès.'
  end


  def set_prestation_exterieure
    @prestation_exterieure = PrestationExterieure.visible_for_admins.find(params[:id] || params[:prestation_exterieure_id])
  end

  def set_home_data
    @conjoints = CafConjoint.where(prestation_exterieure_id: @prestation_exterieure[:id])
    @conjoint = CafConjoint.new(prestation_exterieure_id: @prestation_exterieure[:id])
    @enfants = CafEnfant.joins(:caf_conjoint).where(caf_conjoints: { prestation_exterieure_id: @prestation_exterieure[:id] })
    @enfant = CafEnfant.new
    @localities = Admin::City.where(admin_country_id: @prestation_exterieure[:admin_country_id])
    @beneficiary = CafConjoint.where(prestation_exterieure_id: @prestation_exterieure[:id], is_beneficiary: true).first
    # Start historiques
    @droits_liquidations = @prestation_exterieure.indemnites_prestation_exterieures.page(params[:page]).per(100)
    # End historiques
    @payment_orders = @prestation_exterieure.ordre_paiements.includes(:compta_transactions).order("created_at DESC").page(params[:page]).per(10)
    # indemnities by user connected
    @indemnities = if current_user.gestionnaire_compte_allocataire?
                     @prestation_exterieure.indemnites_prestation_exterieures
                   elsif current_user.chef_subdivision_caf?
                     @prestation_exterieure.indemnites_prestation_exterieures.execute_by_chef_subdivision_caf
                   elsif current_user.chef_groupe_caf?
                     @prestation_exterieure.indemnites_prestation_exterieures.execute_by_chef_groupe_caf
                   elsif current_user.comptable?
                     @prestation_exterieure.indemnites_prestation_exterieures.execute_by_comptable
                   else
                     @prestation_exterieure.indemnites_prestation_exterieures
                   end
  end

  def fill_start_and_end_date
    @prestation_exterieure = PrestationExterieure.visible_for_admins.find_by(id: params[:prest_id])
    debut_period = params[:date_debut]
    fin_period = params[:date_fin]
    children = @prestation_exterieure.enfants_allocataire(debut_period, fin_period) rescue []
    documents = @prestation_exterieure.enfants_documents

    render json: { children: children || [], documents: documents || [] }, status: :ok
  end

  private def prestation_exterieure_params
    prestation_exterieure_params = params.require(:prestation_exterieure).permit(
      :nom, :prenom, :nom_jeune_fille, :type_piece, :nin_salarie, :situation_matrimoniale_salarie,
      :nationalite_salarie, :sexe_salarie, :date_naissance, :lieu_naissance,
      :adresse_pays_origine, :adresse_pays_emploi, :etat, :numero_caf, :piece_justificative_caf,
      :numero_dossier, :numero_secu_social, :motif_rejet_etf, :admin_country_id, :admin_cities_id, :telephone, :email
    )
  end

  private def caf_conjoint_params
    caf_conjoint_params = params.require(:caf_conjoint).permit(:nom, :prenom, :nom_jeune_fille, :date_naissance, :lieu_naissance, :adresse_precise, :date_mariage, :date_separation, :date_divorce, :certificat_mariage, :piece_identite, :etat_couple, :sexe, :prestation_exterieure_id, :type_piece, :nin_conjoint, :certificat_divorce, :certificat_deces)
  end

  private def caf_enfant_params
    caf_enfant_params = params.require(:caf_enfant).permit(:nom, :prenom, :date_naissance, :lieu_naissance, :lien_parente, :observations, :caf_conjoint_id, :type_piece, :numero_piece, :sexe)
  end

  def document_prestation_exterieure_params
    params.require(:document_prestation_exterieure).permit(:type_document, :volet, :document, :commentaire)
  end

  def indemnites_prestation_exterieure_params
    params.require(:indemnites_prestation_exterieure).permit(:date_debut, :date_fin, :motif_retour)
  end


end
