class Psrm::Participant < ApplicationRecord
  self.table_name = 'psrm_participants'
  self.primary_key = 'matric'

  has_many :carrieres, foreign_key: :matric, primary_key: :matric
  # has_many :declaration_carrieres, foreign_key: :matric, primary_key: :matric
  has_many :dossier_prestations, foreign_key: :num_affiliation, primary_key: :matric
  has_many :enfants, foreign_key: :numero_affiliation, primary_key: :matric
  has_many :conjoints, foreign_key: :numero_affiliation, primary_key: :matric
  has_many :cfs_enfants, foreign_key: :numero_affiliation, primary_key: :matric
  has_many :cfs_conjoints, foreign_key: :numero_affiliation, primary_key: :matric
  has_many :bordereau_salaries_assocs, foreign_key: :participant_id, primary_key: :matric
  has_many :salary_modification_historiques, foreign_key: :psrm_participant_id, primary_key: :matric
  # belongs_to :employeur, foreign_key: :fhnum, primary_key: :fhnum

  #scope :employeur_salaries, ->(num_employeur) { joins(dossier_prestations: :carriere_dossier_prestations).where(carriere_dossier_prestations: { num_employeur: num_employeur }).select('psrm_participants.*').distinct }
  scope :employeur_salaries, ->(num_employeur) { joins([dossier_prestations: :participant]).where(dossier_prestations: { employeur_actuel: num_employeur }) }
  #scope :requiert_carrieres_dp, ->(trimestre, annee, num_employeur) { joins([dossier_prestations: :carriere_dossier_prestations]).where(carriere_dossier_prestations: { num_employeur: num_employeur }).where.not(matric: carriere_by_periode(trimestre, annee).pluck(:matric)).where.not(matric: bordereau_by_periode(trimestre, annee).pluck(:matric)).select('psrm_participants.*').distinct }
  scope :requiert_carrieres_dp, ->(trimestre, annee, num_employeur) { joins([dossier_prestations: :participant]).where(dossier_prestations: { employeur_actuel: num_employeur, etat: :valide, conjoint_id: nil }).where.not(matric: carriere_by_periode(trimestre, annee).pluck(:matric)).where.not(matric: bordereau_by_periode(trimestre, annee).pluck(:matric)) }
  scope :requiert_carrieres_dp_after_bordereau_created, ->(trimestre, annee, employeur_id) { joins([bordereau_salaries_assocs: :bordereau_collectif]).where(bordereau_collectifs: { employeur_id: employeur_id, annee: annee, trimestre: trimestre }).select('psrm_participants.*').distinct }
  scope :carriere_by_periode, ->(trimestre, annee) { joins([dossier_prestations: :carriere_dossier_prestations]).where(carriere_dossier_prestations: { trimestre: trimestre, annee: annee }) }
  scope :bordereau_by_periode, ->(trimestre, annee) { joins([bordereau_salaries_assocs: :bordereau_collectif]).where(bordereau_collectifs: { trimestre: trimestre, annee: annee }) }
  #scope :requiert_carrieres_dp, ->(trimestre, annee, num_employeur) { joins([dossier_prestations: :carriere_dossier_prestations]).where(carriere_dossier_prestations: {num_employeur: num_employeur}).where(' ? IS NULL or ? IS NULL', CarriereDossierPrestation.find_by_trimestre(trimestre), CarriereDossierPrestation.find_by_annee(annee)).where(' ? IS NULL or ? IS NULL', BordereauCollectif.find_by_trimestre(trimestre), BordereauCollectif.find_by_annee(annee)).select('psrm_participants.*').distinct }
  scope :has_enfants_eligible, -> { joins(:enfants).where(enfants: { id: Enfant.eligible_for_allocation_f.pluck(:id) }) }
  scope :by_bodereau, ->(bordereau) { joins([bordereau_salaries_assocs: :bordereau_collectif]).where(bordereau_collectifs: { id: bordereau.id }) }

  has_one :liquidation_retraite, foreign_key: :numero_affiliation, primary_key: :matric
  has_one :base_reversion_salary, foreign_key: :numero_affiliation, primary_key: :matric
  has_many :remboursement_cotisations, foreign_key: :numero_affiliation, primary_key: :matric
  has_many :demande_remboursement_cotisations, foreign_key: :numero_affiliation, primary_key: :matric
  has_many :arret_travails, foreign_key: :numero_affiliation, primary_key: :matric
  has_many :dossier_maternites, foreign_key: :num_affiliation, primary_key: :matric

  before_update :save_modifications_historic

  belongs_to :psrm_employeur, :class_name => 'Psrm::Employeur', foreign_key: :id_employeur, primary_key: :fhnum, optional: true

  def declaration_carrieres
    DeclarationCarriere.where(matric: [self.matric, self.ipres_ancien_matric].compact)
  end

  def has_children_not_eligible(period)
    has_children = false
    self.enfants.eligible_for_alloc_familiale(period, self.matric).eligible_plus.each do |enfant|
      if enfant.migrated_document_exp_date?
        next if enfant.migrated_document_exp_date > Date.today
      end
      documents = Document.where(documentable: enfant)
      unless documents.where("date_expiration > ?", Date.today).exists?
        has_children = true
      end
    end
    has_children
  end

  def get_children_not_eligible(period)
    nbr_children = 0
    self.enfants.eligible_for_alloc_familiale(period, self.matric).eligible_plus.each do |enfant|
      documents = Document.where(documentable: enfant)
      unless documents.where("date_expiration > ?", Date.today).exists?
        nbr_children += 1
      end
    end
    nbr_children
  end

  def is_eligible(period)
    self.enfants.eligible_for_alloc_familiale(period, self.matric).length > 0 and self.dossier_prestations.first.has_acceptable_age
  end

  def has_allocations_not_liquided(bordereau)
    self.enfants.joins(:allocation_familiales).where(allocation_familiales: { bordereau_collectif_id: bordereau.id, etat: :creation, document_valid: true }).exists?
  end

  def has_dossier_prestation_familial?
    self.dossier_prestations.exists?(conjoint_id: nil) or femme?
  end

  def has_carriere_dossier_prestation?(bordereau)
    if homme?
      if has_dossier_prestation_familial?
        self.dossier_prestations.where(conjoint_id: nil).first.carriere_dossier_prestations.exists?(trimestre: bordereau.trimestre, annee: bordereau.annee)
      else
        false
      end
    else
      self.dossier_prestations.first.carriere_dossier_prestations.exists?(trimestre: bordereau.trimestre, annee: bordereau.annee)
    end
  end

  def get_carriere_dossier_prestation(bordereau)
    if homme?
      if has_dossier_prestation_familial?
        self.dossier_prestations.where(conjoint_id: nil).first.carriere_dossier_prestations.where(trimestre: bordereau.trimestre, annee: bordereau.annee).first
      else
        false
      end
    else
      self.dossier_prestations.first.carriere_dossier_prestations.where(trimestre: bordereau.trimestre, annee: bordereau.annee).first
    end
  end

  def get_dossier_pf
    self.dossier_prestations.where(conjoint_id: nil).first
  end

  def get_montant_allocations_f(bordereau)
    montant = 0

    if bordereau.normal?
      bordereau_normal = bordereau
    else
      bordereau_normal = BordereauCollectif.where(employeur_id: bordereau.employeur_id, trimestre: bordereau.trimestre, annee: bordereau.annee, bordereau_type: :normal).first
    end

    if bordereau.current_state < :validation_comptable
      allocations = self.enfants.map { |n| n.allocation_familiales.by_bordereau(bordereau_normal).liqui_par_bordereau(bordereau).non_paye.first }
    else
      allocations = self.enfants.map { |n| n.allocation_familiales.by_bordereau(bordereau_normal).liqui_par_bordereau(bordereau).valide.paye.first }
    end

    allocations.each do |allocation|
      unless allocation.nil?
        montant += allocation.montant_paiement
      end
    end
    montant
  end

  def get_dossier_prestationt(trimestre, annee)
    if homme?
      self.dossier_prestations.joins(:carriere_dossier_prestations).where(conjoint_id: nil).where(carriere_dossier_prestations: {trimestre: trimestre, annee: annee}).first
    else
      self.dossier_prestations.joins(:carriere_dossier_prestations).where(carriere_dossier_prestations: {trimestre: trimestre, annee: annee}).first
    end
  end


  def full_name
    "#{prenom} #{nom}"
  end

  def nombre_annee_cotisation
    carrieres.map(&:exercice).uniq.count
  end

  def libelle_regime
    regime
  end

  def homme?
    genre == 'HOMME' # 1
  end

  def femme?
    genre == 'FEMME' # 2
  end

  def nb_jours_travail
    carrieres.map(&:nb_jours_travail).sum
  end

  def nb_mois_travail
    (nb_jours_travail / 30.437).ceil
  end

  def nb_trimestre_travail
    ((nb_jours_travail / 30.437) / 3).ceil
  end

  def date_premiere_embauche
    carrieres.order('date_debut_periode_cotisation DESC').last.try(:date_debut_contrat)
  end

  def date_fin_derniere_embauche
    carrieres.order('date_debut_periode_cotisation DESC').first.try(:date_fin_contrat)
  end

  def dernier_salaire
    c = carrieres.order('date_debut_periode_cotisation DESC').first
    c.nil? ? 0 : c.salaire_rcc + c.salaire_rg
  end

  def derniere_carriere
    carrieres.order('date_debut_periode_cotisation DESC').first
  end

  # en jours
  def duree_derniere_carriere
    c = carrieres.order('date_debut_periode_cotisation DESC').first
    c.nil? ? 0 : (c.date_debut - c.date_fin).to_i + 1
  end

  def duree_derniere_carriere_en_mois
    (duree_derniere_carriere / 30.437).ceil
  end

  def dernier_salaire_mensuel
    c = carrieres.order('date_debut_periode_cotisation DESC').first
    c.nil? ? 0 : (dernier_salaire / 30.437).ceil
  end

  def delai_stage
    nb_mois_travail.to_i - date_premiere_embauche.to_i
  end

  def get_beneficiary
    @beneficiary = Conjoint.where(numero_affiliation: self.matric, est_af_beneficiaire: true).first
  end

  def dernier_employeur
    last_carriere = carrieres.order('date_debut_periode_cotisation DESC').first
    last_carriere.nil? ? "" : last_carriere.fhrsoc
  end

  def save_modifications_historic
    last_info = Psrm::Participant.find(self.id)
    salary_modification = SalaryModificationHistorique.new
    salary_modification.prenom = last_info.prenom
    salary_modification.nom = last_info.nom
    salary_modification.date_naissance = last_info.date_naissance
    salary_modification.phone = last_info.phone
    salary_modification.addr = last_info.addr
    salary_modification.genre = last_info.genre
    salary_modification.numero_piece = last_info.numero_piece
    salary_modification.profession = last_info.profession
    salary_modification.user = User.current
    salary_modification.participant = self
    puts 'error', salary_modification.errors.full_messages unless salary_modification.save
  end

end
