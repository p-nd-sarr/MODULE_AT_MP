class Admin::TraitementCollectifsController < Admin::ApplicationController

  before_action :set_employeur, only: %i[show voir_bordereau generate_bordereau
                  list_bordereau ouvrir_bordereau create_carrieres_dp update_carrieres_dp liquider_bordereau
                    valider_bordereau voir_paiement valider_paiement retourner_bordereau envoyer_bordereau
                     generate_complementary_bordereau ]
  before_action :check_document_before_liquidation, only: %i[ liquider_bordereau ]
  before_action :check_document_before_carrier, only: %i[ create_carrieres_dp ]
  #before_action :check_children_documents_liquidation, only: %i[ liquider_bordereau ]

  def index
    @req = Psrm::Employeur.when_eligible.ransack(params[:q])
    @employeurs = @req.result.page(params[:page]).per(100)

    if params[:annee]
      @cpt = false
      @annee = params[:annee]["presence(1i)"].to_i
      @trimestre = params[:trimestre].to_i
      @employeurs_etat = Psrm::Employeur.when_eligible
      @period = set_period_for_allocation_f(@trimestre, @annee)
      @employeurs_etat.each do |employeur|
        @salaries = Psrm::Participant.requiert_carrieres_dp(@trimestre, @annee, employeur.fhnum).select { |m| m.is_eligible(@period) }
        if @salaries.length > 0
          @cpt = !@cpt
          break
        end
      end
    end
  end

  def en_attente

    if current_user.chef_agence?
      #@req = Psrm::Employeur.joins(bordereau_collectifs: [bordereau_salaries_assocs: [psrm_participant: [enfants: :allocation_familiales]]]).where(allocation_familiales: {etat: 2}).select('psrm_employeurs.*').distinct.ransack(params[:q])
      @req = Psrm::Employeur.joins(:bordereau_collectifs).where(bordereau_collectifs: { workflow_state: :liquidation }).select('psrm_employeurs.*').distinct.ransack(params[:q])
    end

    if current_user.comptable?
      #@req = Psrm::Employeur.joins(bordereau_collectifs: [bordereau_salaries_assocs: [psrm_participant: [enfants: :allocation_familiales]]]).where(allocation_familiales: {etat: 4}).select('psrm_employeurs.*').distinct.ransack(params[:q])
      @req = Psrm::Employeur.joins(:bordereau_collectifs).where(bordereau_collectifs: { workflow_state: :validation_chef_agence }).select('psrm_employeurs.*').distinct.ransack(params[:q])
    end

    @employeurs = @req.result.page(params[:page]).per(100)

  end

  def tr_veuves_en_attente

    if current_user.chef_agence?
      @req = AllocationFamiliale.all.en_agence(current_user.admin_agence.id).soumis.ransack(params[:q])
    end

    if current_user.comptable?
      @req = AllocationFamiliale.all.en_agence(current_user.admin_agence.id).valide.ransack(params[:q])
    end

    @allocations = @req.result.page(params[:page]).per(100)
  end

  def show
    @annee_presence = params[:annee]
    @trimestre_presence = params[:trimestre].to_i
    if params[:annee]
      annee = @annee_presence["presence(1i)"].to_i
      @period = set_period_for_allocation_f(@trimestre_presence, annee)
      @q = Psrm::Participant.requiert_carrieres_dp(@trimestre_presence, annee, @employeur.fhnum).select { |m| m.is_eligible(@period) }
    else
      @q = Psrm::Participant.employeur_salaries(@employeur.fhnum)
    end
    @salaries = @q
  end

  def voir_bordereau
    @annee = params[:annee]
    @trimestre = params[:trimestre]
    @period = set_period_for_allocation_f(@trimestre.to_i, @annee.to_i)

    if BordereauCollectif.exists?(employeur_id: @employeur.id, annee: @annee.to_i, trimestre: @trimestre.to_i)
      @salaries = Psrm::Participant.requiert_carrieres_dp_after_bordereau_created(@trimestre, @annee, @employeur.id)
    else
      @salaries = Psrm::Participant.requiert_carrieres_dp(@trimestre, @annee, @employeur.fhnum).select { |m| m.is_eligible(@period) }
    end

    respond_to do |format|
      format.html
      format.pdf do
        render pdf: "BORDEREAU COLLECTIF",
               page_size: 'A4',
               template: "admin/traitement_collectifs/generated_bordereau.html.erb",
               layout: "pdf.html",
               orientation: "Landscape",
               lowquality: true,
               zoom: 1,
               pi: 75
      end
    end
  end

  def generate_all_bordereau

    @employeurs_etat = Psrm::Employeur.when_eligible
    pdf = CombinePDF.new
    @annee = params[:annee].to_i
    @trimestre = params[:trimestre].to_i

    @period = set_period_for_allocation_f(@trimestre, @annee)

    respond_to do |format|
      format.html
      format.pdf do
        @employeurs_etat.each do |employeur|
          @employeur = employeur
          @salaries = Psrm::Participant.requiert_carrieres_dp(@trimestre, @annee, employeur.fhnum).select { |m| m.is_eligible(@period) }
          if @salaries.length > 0
            generated_pdf = render_to_string pdf: "BORDEREAU COLLECTIF",
                                             page_size: 'A4',
                                             template: "admin/traitement_collectifs/generated_bordereau.html.erb",
                                             layout: "pdf.html",
                                             orientation: "Landscape",
                                             lowquality: true,
                                             zoom: 1,
                                             pi: 75
            pdf << CombinePDF.parse(generated_pdf)
          end
        end

        if pdf.pages.length > 0
          pdf_first_page = pdf.pages[0]
          mediabox = pdf_first_page[:CropBox] || pdf_first_page[:MediaBox]
          title_page = CombinePDF.create_page mediabox
          full_name = 'Etats de controle du TRIMESTRE ' + @trimestre.to_s + " de l'ANNEE " + @annee.to_s
          title_page.textbox full_name, font_color: [0.8, 0, 0], font_size: :fit_text, box_color: [1, 0.8, 0.8], opacity: 1
          pdf >> title_page
          pdf.number_pages location: [:bottom_right], number_format: 'Page %s', font_size: 10, opacity: 0.5
          send_data pdf.to_pdf, filename: "etat_control.pdf", type: "application/pdf"
        end
      end
    end

  end

  def generate_bordereau
    @annee = params[:annee]
    @trimestre = params[:trimestre]
    @period = set_period_for_allocation_f(@trimestre.to_i, @annee.to_i)
    @salaries = Psrm::Participant.requiert_carrieres_dp(@trimestre, @annee, @employeur.fhnum).select { |m| m.is_eligible(@period) }
    bordereau = BordereauCollectif.new
    bordereau.employeur_id = @employeur.id
    bordereau.trimestre = @trimestre
    bordereau.annee = @annee
    bordereau.assign_params_from_controller(@employeur, @salaries)
    bordereau.save!
    redirect_to admin_traitement_collectif_path(@employeur.fhnum), notice: "Le bordereau a été enregistré avec succès."
  end

  def list_bordereau
    @req = BordereauCollectif.where(employeur_id: @employeur.id).ransack(params[:q])
    @bordereaux = @req.result.page(params[:page]).per(100)

  end

  def generate_complementary_bordereau
    @bordereau_normal = BordereauCollectif.find_by_numero_bordereau(params[:num_bordereau])
    @annee = @bordereau_normal.annee
    @trimestre = @bordereau_normal.trimestre
    @period = set_period_for_allocation_f(@trimestre.to_i, @annee.to_i)
    #@salaries = Psrm::Participant.requiert_carrieres_dp(@trimestre, @annee, @employeur.fhnum).select { |m| m.is_eligible(@period) }
    @salaries = Psrm::Participant.by_bodereau(@bordereau_normal).select { |m| m.has_allocations_not_liquided(@bordereau_normal) }

    if @salaries.length > 0
      bordereau = BordereauCollectif.new
      bordereau.bordereau_type = BordereauCollectif.bordereau_types[:complementaire]
      bordereau.employeur_id = @employeur.id
      bordereau.trimestre = @bordereau_normal.trimestre
      bordereau.annee = @bordereau_normal.annee
      bordereau.assign_params_from_controller(@employeur, @salaries)
      bordereau.save
      redirect_to admin_traitement_collectif_ouvrir_bordereau_path(@employeur.fhnum, bordereau.numero_bordereau), notice: "Le bordereau complémentaire a été créé avec succès."
    else
      flash[:error] = 'Aucun salarié à ajouter dans le bordereau complémentaire.'
      redirect_to admin_traitement_collectif_list_bordereau_path(@employeur.fhnum)
    end
  end

  def ouvrir_bordereau
    @dossier_prestation = DossierPrestation.new
    @carriere_dossier_prestation = CarriereDossierPrestation.new
    @bordereau = BordereauCollectif.find_by_numero_bordereau(params[:num_bordereau])
    @bordereau_normal = BordereauCollectif.where(employeur_id: @bordereau.employeur_id, trimestre: @bordereau.trimestre, annee: @bordereau.annee, bordereau_type: :normal).first
    @q = Psrm::Participant.joins(:bordereau_salaries_assocs).where(bordereau_salaries_assocs: { bordereau_collectif_id: @bordereau.id }).ransack(params[:q])
    @salaries = @q.result.page(params[:page]).per(100)
    @period = set_period_for_allocation_f(@bordereau.trimestre, @bordereau.annee)
  end

  def create_carrieres_dp
    @matric = params[:num_affiliation]
    @salary = Psrm::Participant.find_by_matric(@matric)
    @bordereau = BordereauCollectif.find_by_numero_bordereau(params[:num_bordereau])
    @dossier_prestation = @salary.homme? ? @salary.get_dossier_pf : @salary.dossier_prestations.first
    @carriere_dossier_prestation = CarriereDossierPrestation.new(carriere_dossier_prestation_params)
    @carriere_dossier_prestation.trimestre = @bordereau.trimestre
    @carriere_dossier_prestation.annee = @bordereau.annee
    @carriere_dossier_prestation.num_employeur = @employeur.fhnum
    @carriere_dossier_prestation.raison_sociale = @employeur.fhrsoc
    @carriere_dossier_prestation.dossier_prestation_id = @dossier_prestation.id
    @carriere_dossier_prestation.date_depot = Date.today
    @carriere_dossier_prestation.bordereau_collectif_id = @bordereau.id

    if @carriere_dossier_prestation.save
      redirect_to admin_traitement_collectif_ouvrir_bordereau_path(@employeur.fhnum, @bordereau.numero_bordereau, @matric), notice: 'Les temps de présence ont été ajoutés avec succès.'
    else
      @bordereau = BordereauCollectif.find_by_numero_bordereau(params[:num_bordereau])
      @q = Psrm::Participant.joins(:bordereau_salaries_assocs).where(bordereau_salaries_assocs: { bordereau_collectif_id: @bordereau.id }).ransack(params[:q])
      @salaries = @q.result.page(params[:page]).per(100)
      render :ouvrir_bordereau
    end
  end

  def fill_all_carriers
    @bordereau = BordereauCollectif.find_by_numero_bordereau(params[:num_bordereau])
    @salaries = Psrm::Participant.by_bodereau(@bordereau)
    nb_days = 18
    @salaries.each do |salary|
      dossier_prestation = salary.homme? ? salary.get_dossier_pf : salary.dossier_prestations.first
      carriere_dossier_prestation = CarriereDossierPrestation.new
      carriere_dossier_prestation.premier_mois = nb_days
      carriere_dossier_prestation.deuxiem_mois = nb_days
      carriere_dossier_prestation.troisiem_mois = nb_days
      carriere_dossier_prestation.trimestre = @bordereau.trimestre
      carriere_dossier_prestation.annee = @bordereau.annee
      carriere_dossier_prestation.num_employeur = @bordereau.psrm_employeur.fhnum
      carriere_dossier_prestation.raison_sociale = @bordereau.psrm_employeur.fhrsoc
      carriere_dossier_prestation.dossier_prestation_id = dossier_prestation.id
      carriere_dossier_prestation.date_depot = Date.today
      carriere_dossier_prestation.bordereau_collectif_id = @bordereau.id
      carriere_dossier_prestation.save
    end

    redirect_to admin_traitement_collectif_ouvrir_bordereau_path(@bordereau.psrm_employeur.fhnum, @bordereau.numero_bordereau), notice: 'Les temps de présence ont été ajoutés avec succès.'
  end

  def clear_all_carriers
    @bordereau = BordereauCollectif.find_by_numero_bordereau(params[:num_bordereau])
    @salaries = Psrm::Participant.by_bodereau(@bordereau)
    @salaries.each do |salary|
      dossier_prestation = salary.homme? ? salary.get_dossier_pf : salary.dossier_prestations.first
      carriere_dossier_prestation = CarriereDossierPrestation.find_by(dossier_prestation_id: dossier_prestation.id, trimestre: @bordereau.trimestre, annee: @bordereau.annee)
      carriere_dossier_prestation.destroy
    end

    redirect_to admin_traitement_collectif_ouvrir_bordereau_path(@bordereau.psrm_employeur.fhnum, @bordereau.numero_bordereau), notice: 'Les temps de présence ont été suupprimés avec succès.'
  end

  def update_carrieres_dp
    @carriere_dossier_prestation = CarriereDossierPrestation.find(params[:id_carriere])
    @matric = params[:num_affiliation]
    @salary = Psrm::Participant.find_by_matric(@matric)
    @bordereau = BordereauCollectif.find_by_numero_bordereau(params[:num_bordereau])
    @dossier_prestation = @salary.homme? ? @salary.get_dossier_pf : @salary.dossier_prestations.first
    @carriere_dossier_prestation.bordereau_collectif_id = @bordereau.id

    if @carriere_dossier_prestation.update(carriere_dossier_prestation_params)
      redirect_to admin_traitement_collectif_ouvrir_bordereau_path(@employeur.fhnum, @bordereau.numero_bordereau, @matric), notice: 'Les temps de présence ont été modifiés avec succès.'
    else
      @employeur = Psrm::Employeur.find_by_fhnum(params[:id] || params[:traitement_collectif_id])
      @bordereau = BordereauCollectif.find_by_numero_bordereau(params[:num_bordereau])
      @q = Psrm::Participant.joins(:bordereau_salaries_assocs).where(bordereau_salaries_assocs: { bordereau_collectif_id: @bordereau.id }).ransack(params[:q])
      @salaries = @q.result.page(params[:page]).per(100)
      render :ouvrir_bordereau
    end
  end

  def liquider_bordereau
    @bordereau = BordereauCollectif.find_by_numero_bordereau(params[:num_bordereau])

    if @bordereau.normal?
      @bordereau_normal = @bordereau
    else
      @bordereau_normal = BordereauCollectif.where(employeur_id: @employeur.id, trimestre: @bordereau.trimestre, annee: @bordereau.annee, bordereau_type: :normal).first
    end

    @bordereau_normal.allocation_familiales.creation.when_document_valid.each do |allocation|
      allocation.soumis!
      allocation.date_soumission = Date.today
      allocation.date_liquidation = Date.today
      allocation.montant_paiement = allocation.montant_a_payer
      allocation.liquide_par_bordereau = @bordereau
      allocation.save
    end

    if @bordereau.creation?
      @bordereau.est_liquide!
      @bordereau.liquide_par = current_user
      @bordereau.date_liquidation = Date.today
      @bordereau.motif_rejet = nil
      @bordereau.save!
    end
    redirect_to admin_traitement_collectif_ouvrir_bordereau_path(@employeur.fhnum, @bordereau.numero_bordereau), notice: 'Le bordereau a été liquidé avec succès.'
  end

  def liquider_all_bordereau
    @employeurs = Psrm::Employeur.when_eligible
    @completed_bordereau = BordereauCollectif.workflow_state('creation').select { |m| m.is_all_completed? }
    completed_size = @completed_bordereau.count
    @completed_bordereau.each do |item|
      item.liquider
    end
    redirect_to admin_traitement_collectifs_path, notice: completed_size.to_s + " bordereau(x) liquidé(s) avec succès."
  end

  def valider_bordereau
    @bordereau = BordereauCollectif.find_by_numero_bordereau(params[:num_bordereau])

    if @bordereau.normal?
      @bordereau_normal = @bordereau
    else
      @bordereau_normal = BordereauCollectif.where(employeur_id: @employeur.id, trimestre: @bordereau.trimestre, annee: @bordereau.annee, bordereau_type: :normal).first
    end

    @bordereau_normal.allocation_familiales.liqui_par_bordereau(@bordereau).each do |allocation|
      if allocation.soumis?
        allocation.traite_par = current_user
        allocation.traite_le = DateTime.now
        allocation.date_validation = Date.today
        allocation.valide!
        allocation.save
      end
    end

    if @bordereau.liquidation?
      @bordereau.est_valide_chef_agence!
      @bordereau.valide_chef_agence_par = current_user
      @bordereau.date_validation_chef_agence = Date.today
      @bordereau.motif_rejet = nil
      @bordereau.save!
    end
    redirect_to admin_traitement_collectif_ouvrir_bordereau_path(@employeur.fhnum, @bordereau.numero_bordereau), notice: 'Le bordereau a été validé avec succès.'
  end

  def voir_paiement
    @bordereau = BordereauCollectif.find_by_numero_bordereau(params[:num_bordereau])
    @salaries = Psrm::Participant.joins(:bordereau_salaries_assocs).where(bordereau_salaries_assocs: { bordereau_collectif_id: @bordereau.id })
    #@allocations = AllocationFamiliale.joins(enfant: [participant: [bordereau_salaries_assocs: :bordereau_collectif]]).where(bordereau_collectifs: {id: @bordereau.id})
    @period = set_period_for_allocation_f(@bordereau.trimestre, @bordereau.annee)

    respond_to do |format|
      format.html
      format.pdf do
        render pdf: "ORDRE DE PAIEMENT COLLECTIF",
               page_size: 'A4',
               template: "admin/traitement_collectifs/generated_order.html.erb",
               layout: "pdf.html",
               orientation: "Landscape",
               lowquality: true,
               zoom: 1,
               pi: 75
      end
    end
  end

  def valider_paiement
    @bordereau = BordereauCollectif.find_by_numero_bordereau(params[:num_bordereau])
    if @bordereau.normal?
      @bordereau_normal = @bordereau
    else
      @bordereau_normal = BordereauCollectif.where(employeur_id: @employeur.id, trimestre: @bordereau.trimestre, annee: @bordereau.annee, bordereau_type: :normal).first
    end
    @salaries = Psrm::Participant.joins(:bordereau_salaries_assocs).where(bordereau_salaries_assocs: { bordereau_collectif_id: @bordereau.id })
    montant_bordereau = @salaries.inject(0) { |sum, salary| sum + salary.get_montant_allocations_f(@bordereau) }

    @salaries.each do |salary|
      dossier_prestation = salary.get_dossier_prestationt(@bordereau.trimestre, @bordereau.annee)
      paiement = PaiementAllocataire.new
      paiement.numero_allocataire = salary.matric
      paiement.etat = :en_attente_paiement
      paiement.montant_brut = salary.get_montant_allocations_f(@bordereau)
      paiement.montant_net = salary.get_montant_allocations_f(@bordereau)
      paiement.annee = Date.today.year
      paiement.periode = :immediate
      paiement.code = dossier_prestation.generate_reference
      paiement.numero_paiement = dossier_prestation.generate_reference
      paiement.date_generation = Date.today
      #@allocations = AllocationFamiliale.joins(enfant: [participant: [bordereau_salaries_assocs: :bordereau_collectif]]).where(bordereau_collectifs: { id: @bordereau.id }).where(psrm_participants: { matric: salary.matric }).valide.non_paye
      if paiement.save
        @bordereau_normal.allocation_familiales.liqui_par_bordereau(@bordereau).each do |allocation|
          allocation.traite_par = current_user
          allocation.paiement = true
          allocation.paiement_id = paiement.id
          allocation.save
        end
      end
    end
    if @bordereau.validation_chef_agence?
      @bordereau.est_valide_comptable!
      @bordereau.valide_comptable_par = current_user
      @bordereau.date_validation_comptable = Date.today
      @bordereau.save!
    end
    redirect_to admin_traitement_collectif_list_bordereau_path(@employeur.fhnum), notice: 'Le paiement a été validé avec succès.'

  end

  def retourner_bordereau
    @bordereau = BordereauCollectif.find_by_numero_bordereau(params[:num_bordereau])

    if @bordereau.liquidation?
      @bordereau.retour_creation!
    end

    if @bordereau.validation_chef_agence?
      @bordereau.retour_liquidation!
    end

    if @bordereau.update(bordereau_params)
      redirect_to admin_tr_en_attente_path, notice: 'Le bordereau a été rejeté avec succès.'
    end

  end

  def envoyer_bordereau
    @bordereau = BordereauCollectif.find_by_numero_bordereau(params[:num_bordereau])
    @period = set_period_for_allocation_f(@bordereau.trimestre, @bordereau.annee)
    @salaries = Psrm::Participant.requiert_carrieres_dp_after_bordereau_created(@bordereau.trimestre, @bordereau.annee, @bordereau.employeur_id)
    mandataire = Admin::Mandataire.where(numero_employeur: @bordereau.psrm_employeur.fhnum).last

    unless mandataire.nil?
      email = mandataire.email
      unless email.nil? or email.empty?
        if email =~ /\A([^@\s]+)@((?:[-a-z0-9]+\.)+[a-z]{2,})\z/i
          BordereauMailer.new_bordereau_mail(email, @employeur, @salaries, @period).deliver
          redirect_to admin_traitement_collectif_ouvrir_bordereau_path(@employeur.fhnum, @bordereau.numero_bordereau), notice: 'Le bordereau a été envoyé avec succès.'
        else
          flash[:error] = 'Format email incorrect.'
          redirect_to admin_traitement_collectif_ouvrir_bordereau_path(@employeur.fhnum, @bordereau.numero_bordereau)
        end
      else
        flash[:error] = 'Adresse email introuvable.'
        redirect_to admin_traitement_collectif_ouvrir_bordereau_path(@employeur.fhnum, @bordereau.numero_bordereau)
      end
    else
      flash[:error] = 'Aucun mandataire enregistré pour cet employeur.'
      redirect_to admin_traitement_collectif_ouvrir_bordereau_path(@employeur.fhnum, @bordereau.numero_bordereau)
    end
  end

  def check_document_before_liquidation

    @bordereau = BordereauCollectif.find_by_numero_bordereau(params[:num_bordereau])

    unless @bordereau.document.attached?
      flash[:error] = 'Vous devez ajouyer le document justificatif!.'
      redirect_to admin_traitement_collectif_ouvrir_bordereau_path(@employeur.fhnum, @bordereau.numero_bordereau)
    end
  end

  def allocations_list
    @annee_presence = params[:annee]
    @trimestre_presence = params[:trimestre].to_i
    if params[:annee]
      annee = @annee_presence["presence(1i)"].to_i
      if current_user.gestionnaire_compte_allocataire?
        @allocations = AllocationFamiliale.from_maintein_by_death.by_periode(@trimestre_presence, annee).en_agence(current_user.agence.id).en_attente_liquidation
      end
      if current_user.chef_agence?
        @allocations = AllocationFamiliale.from_maintein_by_death.by_periode(@trimestre_presence, annee).en_agence(current_user.agence.id).en_attente_validation
      end
      if current_user.comptable?
        @allocations = AllocationFamiliale.from_maintein_by_death.by_periode(@trimestre_presence, annee).en_agence(current_user.agence.id).en_attente_validation_paiement.non_paye
      end
    else
      @allocations = AllocationFamiliale.none
    end
  end

  def liquider_allocations_from_maintien
    @annee_presence = params[:annee]
    @trimestre_presence = params[:trimestre].to_i
    if params[:annee]
      annee = @annee_presence["presence(1i)"].to_i
      allocations = AllocationFamiliale.from_maintein_by_death.by_periode(@trimestre_presence, @annee_presence.to_i).en_agence(current_user.agence.id).en_attente_liquidation.when_document_valid
      allocations.each do |allocation|
        unless allocation.nil?
          allocation.soumis!
          allocation.date_soumission = Date.today
          allocation.date_liquidation = Date.today
          if allocation.montant_paiement.nil?
            allocation.montant_paiement = allocation.montant_a_payer
          end
          allocation.save
        end
      end
    end
    redirect_to admin_allocations_list_path, notice: "Les allocations ont été liquidées avec succès."
  end

  def valider_allocations_from_maintien
    @annee_presence = params[:annee]
    @trimestre_presence = params[:trimestre].to_i
    if params[:annee]
      annee = @annee_presence["presence(1i)"].to_i
      allocations = AllocationFamiliale.from_maintein_by_death.by_periode(@trimestre_presence, @annee_presence.to_i).en_agence(current_user.agence.id).en_attente_validation
    else
      allocations = AllocationFamiliale.from_maintein_by_death.en_agence(current_user.agence.id).en_attente_validation
    end
    allocations.each do |allocation|
      unless allocation.nil?
        if allocation.soumis?
          allocation.traite_par = current_user
          allocation.traite_le = DateTime.now
          allocation.date_validation = Date.today
          allocation.valide!
          allocation.save
        end
      end
    end
    if params[:annee]
      redirect_to admin_allocations_list_path, notice: "Les allocations ont été validées avec succès."
    else
      redirect_to admin_tr_veuves_en_attente_path, notice: "Les allocations ont été validées avec succès."
    end
  end

  def valider_paiement_from_maintien
    @annee_presence = params[:annee]
    @trimestre_presence = params[:trimestre].to_i
    if params[:annee]
      annee = @annee_presence["presence(1i)"].to_i
      allocations = AllocationFamiliale.from_maintein_by_death.by_periode(@trimestre_presence, @annee_presence.to_i).en_agence(current_user.agence.id).valide.non_paye
    else
      allocations = AllocationFamiliale.from_maintein_by_death.en_agence(current_user.agence.id).valide.non_paye
    end

    dossiers = allocations.map { |allocation| allocation.dossier_prestation }.uniq
    dossiers.each do |dossier|
      ValiderPaiementsDossierPrestationJob.perform_later(dossier, current_user, @trimestre_presence, @annee_presence.to_i)
    end
    if params[:annee]
      redirect_to admin_allocations_list_path, notice: "Génération des ordres de paiement en cours."
    else
      redirect_to admin_tr_veuves_en_attente_path, notice: "Génération des ordres de paiement en cours."
    end

  end

  def check_children_documents_liquidation
    @bordereau = BordereauCollectif.find_by_numero_bordereau(params[:num_bordereau])
    return if @bordereau.normal?

    @bordereau_normal = BordereauCollectif.where(employeur_id: @bordereau.employeur_id, trimestre: @bordereau.trimestre, annee: @bordereau.annee, bordereau_type: :normal).first

    if @bordereau_normal.allocation_familiales.creation.where(document_valid: false).exists?
      flash[:error] = 'Vous devez mettre à jour les documents des enfnats'
      redirect_to admin_traitement_collectif_ouvrir_bordereau_path(@employeur.fhnum, @bordereau.numero_bordereau)
    end
  end

  private

  def check_document_before_carrier
    @bordereau = BordereauCollectif.find_by_numero_bordereau(params[:num_bordereau])

    unless @bordereau.document.attached?
      flash[:error] = 'Vous devez ajouyer le document justificatif!.'
      redirect_to admin_traitement_collectif_ouvrir_bordereau_path(@employeur.fhnum, @bordereau.numero_bordereau)
    end
  end

  def set_employeur
    @employeur = Psrm::Employeur.find_by_fhnum(params[:id] || params[:traitement_collectif_id])
  end

  def bordereau_params
    params.require(:bordereau_collectif).permit(:motif_rejet)
  end

  def carriere_dossier_prestation_params
    params.require(:carriere_dossier_prestation).permit(:num_employeur, :raison_sociale, :document, :date_document,
                                                        :trimestre, :premier_mois, :deuxiem_mois, :troisiem_mois, :annee, :infos_jour, :infos_heure,
                                                        :est_justifier_mois2, :est_justifier, :est_justifier_mois3, :motif_mois1, :motif_mois2,
                                                        :motif_mois3)
  end

end

