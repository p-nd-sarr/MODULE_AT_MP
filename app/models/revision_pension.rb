class RevisionPension < ApplicationRecord
  include MyTools

  include WorkflowActiverecord

  InvalidTransitionError = Class.new(StandardError)
  workflow_column :workflow_state

  workflow do
    state :creation, :meta => { label: 'Création' } do
      event :est_soumis, transition_to: :soumis
    end

    state :soumis, :meta => { label: 'Soumis' } do
      event :est_instruit, transition_to: :instruit
      event :retour_creation, transition_to: :creation
    end

    state :instruit, :meta => { label: 'Instruit' } do
      event :est_carriere_soumis, transition_to: :carriere_soumis
      event :retour_soumis, transition_to: :soumis
    end

    state :carriere_soumis, :meta => { label: 'Carrière soumis' } do
      event :est_carriere_valide, transition_to: :cotisation_valide
      event :retour_instruit, transition_to: :instruit
    end

    state :cotisation_valide, :meta => { label: 'Cotisation validée' } do
      event :est_recap_soumis, transition_to: :recap_soumis
      event :retour_carriere_soumis, transition_to: :carriere_soumis
    end

    state :recap_soumis, :meta => { label: 'Recap soumis' } do
      event :est_recap_valide, transition_to: :liquidation_valide
      event :retour_cotisation_valide, transition_to: :cotisation_valide

    end

    state :liquidation_valide, :meta => { label: 'Liquidation validée' } do
      event :est_dossier_valide, transition_to: :valider
      event :est_dossier_rejete, transition_to: :rejeter
      event :retour_recap_soumis, transition_to: :recap_soumis
    end

    state :valider, :meta => { label: 'Validée' } do
      event :est_valide_cs, transition_to: :valider_directeur
      event :est_dossier_rejete, transition_to: :rejeter
      event :retour_liquidation_valide, transition_to: :liquidation_valide
    end

    state :valider_directeur, :meta => { label: 'Validation directeur' } do
      event :est_valide_revision, transition_to: :valider_revision
      event :est_dossier_rejete, transition_to: :rejeter
      event :retour_valider, transition_to: :valider
    end

    state :rejeter, :meta => { label: 'Rejetée' }
    state :valider_revision, :meta => { label: 'Validée' }

    on_transition do |from, to, triggering_event, *event_args|
      puts "#{from} -> #{to}"
    end

    #  use after transition for historisation
    after_transition do
      puts " => traite par : #{self.traite_par} "
    end

    on_error do |error, from, to, event, *args|
      puts "Exception(#error.class) on #{from} -> #{to}"
    end

  end

  TYPE_MOTIF = {
      justification_carriere: 1,
      integration_carriere: 2,
      justification_integration: 3
  }.freeze

  enum type_motif: TYPE_MOTIF

  has_one_attached :document

  before_create :set_numero_dossier

  validates :type_motif, :presence => true

  validate :validate_date!

  belongs_to :traite_par, class_name: 'User', foreign_key: :traite_par_id, optional: true
  belongs_to :retourne_par, class_name: 'User', foreign_key: :retourne_par_id, optional: true
  belongs_to :ajouter_par, class_name: 'User', foreign_key: :ajouter_par_id, optional: true
  belongs_to :instruit_par, class_name: 'User', foreign_key: :instruit_par_id, optional: true
  belongs_to :valider_par, class_name: 'User', foreign_key: :valider_par_id, optional: true
  belongs_to :soumis_par, class_name: 'User', foreign_key: :soumis_par_id, optional: true
  belongs_to :affectation_allocataire, class_name: 'User', foreign_key: :affecter_allocataire, optional: true
  belongs_to :affectation_salarie, class_name: 'User', foreign_key: :affecter_salarie, optional: true
  belongs_to :allocataire, class_name: 'Allocataire', foreign_key: :allocation_id
  belongs_to :admin_agence, class_name: 'Admin::Agence', foreign_key: :admin_agence_id

  has_many :carrieres_prestation, class_name: 'Carriere', foreign_key: :numero_affiliation, primary_key: :numero_allocataire
  has_many :carrieres, class_name: 'Carriere', foreign_key: :revision_pension_id
  has_many :montant_revisions, class_name: 'MontantRevision', foreign_key: :revision_pension_id

  has_many :workflow_histories, foreign_key: :dossier_id

  scope :en_attente_salaire, -> { where(workflow_state: [:instruit]).where(affectation_salarie: nil) }

  scope :en_attente_allocation, -> { where(workflow_state: [:instruit, :carriere_soumis, :cotisation_valide]).where(affectation_allocataire: nil) }
  scope :en_attente_instruction, -> { where(workflow_state: [:soumis]) }

  scope :can_affecte, -> { where(workflow_state: [:instruit, :carriere_soumis, :cotisation_valide, :recap_soumis, :liquidation_valide]) }

  after_save :create_allocataire_suivi!

  after_save :regenerate_montant_revisions!
  after_save :generate_compta_transaction

  def carrieres_prestation
    carrieres
  end

  def pret_pour_soumission?
    true
  end

  def date_debut_revision
    allocataire.date_jouissance.try(:beginning_of_month)
  end

  def date_fin_revision
    montant_revisions.maximum(:periode_fin)
  end

=begin
  def regenerate_montant_revisions!
    if cotisation_valide? and montant_revisions.empty?
      date_jouissance = allocataire.date_jouissance

      if allocataire.versement_unique?
        dates_cles = [date_jouissance, date_jouissance.end_of_month]
      else

        premiere_annee = date_jouissance.year
        derniere_annee = Date.today.year

        dates_cles = (premiere_annee..derniere_annee).to_a.map { |annee| Date.new(annee).end_of_year }

        dates_cles << date_jouissance << Date.today.beginning_of_month - 1.day


        dates_cles += allocataire.dates_sorties_enfants_periode(date_jouissance, Date.today.beginning_of_month - 1.day).map {
            |d| d.end_of_month
        }


        if Date.today.beginning_of_month == date_jouissance.beginning_of_month
          dates_cles << date_jouissance.end_of_month
        end


        dates_cles.sort!.uniq!
        dates_cles.delete_if { |x| x > Date.today.end_of_month or x < date_jouissance }
      end

      periode_debut = dates_cles.first
      dates_cles[1..-1].each do |periode_fin|
        montant_revisions.create(
            annee: periode_debut.year,
            periode_debut: periode_debut,
            periode_fin: periode_fin
        )
        periode_debut = periode_fin + 1.day
      end
    end
  end

=end

  def regenerate_montant_revisions!
    if cotisation_valide? and montant_revisions.empty?
      date_jouissance = allocataire.date_jouissance

      if allocataire.versement_unique? and ((allocataire.points_base_rg + calcul_points_base_regime_general) < 1000)
        later_date = date_jouissance.end_of_month
      else
        later_date = Date.today.next_month.end_of_month
      end

      save_revision_amount_by_period(date_jouissance, later_date)
      set_allocataire_backup
      update_allocataire
    end
  end

  def set_allocataire_backup(clear = false)
    last_updated_revision = self.montant_revisions.last
    self.update(
      previous_points_rc: (clear ? nil : allocataire.points_rc),
      previous_points_base_rc: (clear ? nil : allocataire.points_base_rc),
      previous_point_majoration_rc: (clear ? nil : allocataire.point_majoration_rc),
      previous_point_minoration_rc: (clear ? nil : allocataire.point_minoration_rc),
      previous_points_servis_rc: (clear ? nil : allocataire.points_servis_rc),

      previous_points_rg: (clear ? nil : allocataire.points_rg),
      previous_points_base_rg: (clear ? nil : allocataire.points_base_rg),
      previous_point_majoration_rg: (clear ? nil : allocataire.point_majoration_rg),
      previous_point_minoration_rg: (clear ? nil : allocataire.point_minoration_rg),
      previous_points_servis_rg: (clear ? nil : allocataire.points_servis_rg))
  end

  def update_allocataire(add = true)
    last_updated_revision = self.montant_revisions.last
    allocataire.update(
      points_rc: (add ? allocataire.points_rc + last_updated_revision.points_cotisation_rc : previous_points_rc),
      points_base_rc: (add ? allocataire.points_base_rc + last_updated_revision.points_base_rc : previous_points_base_rc),
      point_majoration_rc: (add ? last_updated_revision.points_majoration_rc : previous_point_majoration_rc),
      point_minoration_rc: (add ? last_updated_revision.points_minoration_rc : previous_point_minoration_rc),
      points_servis_rc: (add ? allocataire.points_servis_rc + last_updated_revision.points_servis_rc : previous_points_servis_rc),

      points_rg: (add ? allocataire.points_rg + last_updated_revision.points_cotisation_rg : previous_points_rg),
      points_base_rg: (add ? allocataire.points_base_rg + last_updated_revision.points_base_rg : previous_points_base_rg),
      point_majoration_rg: (add ? last_updated_revision.points_majoration_rg : previous_point_majoration_rg),
      point_minoration_rg: (add ? last_updated_revision.points_minoration_rg : previous_point_minoration_rg),
      points_servis_rg: (add ? allocataire.points_servis_rg + last_updated_revision.points_servis_rg : previous_points_servis_rg))

    if allocataire.eteint? and allocataire.points_rg >= 1000
      allocataire.etat = Allocataire.etats[:actif]
      allocataire.versement_unique = false
    end
    if allocataire.actif? and allocataire.points_rg < 1000
      allocataire.etat = Allocataire.etats[:eteint]
      allocataire.versement_unique = true
    end
    allocataire.save
  end

  # montant revision : save by period
  def save_revision_amount_by_period(debut_period, fin_period)
    (debut_period.year..fin_period.year).each do |y|
      mo_start = (debut_period.year == y) ? debut_period.month : 1
      mo_end = (fin_period.year == y) ? fin_period.month : 12

      (mo_start..mo_end).each do |m|
        #puts Date::MONTHNAMES[m]
        fin = Date.new(y, m, 1).end_of_month
        debut = debut_period.between?(Date.new(y, m, 1), fin) ? debut_period : Date.new(y, m, 1)
        montant_revisions.create(
          annee: y,
          periode_debut: debut,
          periode_fin: fin,
        )
      end

    end
  end

  def calcul_points_base_regime_general
    (calcul_points_regime_general + calcul_points_gratuits_regime_general - calcul_points_minoration_regime_general).ceil
  end

  def calcul_points_regime_general
    carrieres.valide.regime_general.sum(:points)
  end

  def calcul_points_gratuits_regime_general
    (carrieres.valide.regime_general.sum(&:points_gratuits)).ceil
  end

  def calcul_points_minoration_regime_general
    carrieres.valide.regime_general.map do |carriere|
      (1.0 * (carriere.points + carriere.points_gratuits) * taux_minoration_rg / 100)
    end.sum.round
  end

  def taux_minoration_rg
    allocataire.pourcentage_minoration_rg
  end

  #region : calcul montant revision
  def points_cotisation
    montant_revisions.empty? ? 0 : montant_revisions.first.points_cotisation
  end

  def points_minoration
    montant_revisions.empty? ? 0 : montant_revisions.first.points_minoration
  end

  def points_base
    montant_revisions.empty? ? 0 : montant_revisions.first.points_base
  end

  def points_gratuits_rc
    montant_revisions.empty? ? 0 : montant_revisions.first.points_gratuits_rc
  end

  def points_gratuits
    montant_revisions.empty? ? 0 : montant_revisions.first.points_gratuits
  end

  def points_cotisation_rc
    montant_revisions.empty? ? 0 : montant_revisions.first.points_cotisation_rc
  end

  def points_minoration_rc
    montant_revisions.empty? ? 0 : montant_revisions.first.points_minoration_rc
  end

  def points_majoration_rc
    montant_revisions.empty? ? 0 : montant_revisions.first.points_majoration_rc
  end

  def points_base_rc
    montant_revisions.empty? ? 0 : montant_revisions.first.points_base_rc
  end

  def points_cotisation_rg
    montant_revisions.empty? ? 0 : montant_revisions.first.points_cotisation_rg
  end

  def points_minoration_rg
    montant_revisions.empty? ? 0 : montant_revisions.first.points_minoration_rg
  end

  def points_majoration_rg
    montant_revisions.empty? ? 0 : montant_revisions.first.points_majoration_rg
  end

  def points_base_rg
    montant_revisions.empty? ? 0 : montant_revisions.first.points_base_rg
  end

  def points_gratuits_rg
    montant_revisions.empty? ? 0 : montant_revisions.first.points_gratuits_rg
  end

  def montant_revision_rc
    montant_revisions.sum(:montant_revision_rc)
  end

  def montant_revision_rg
    montant_revisions.sum(:montant_revision_rg)
  end

  def montant_revision_total
    montant_revisions.sum(:montant_revision_total)
  end

  #endregion calcul montant revision

  def generate_compta_transaction
    if valider_revision? and not ComptaTransaction.exists?(dossier: self)
      op = OrdrePaiement.create(dossier: self, numero_allocataire: numero_allocataire)

      ComptaTransaction.create(
        dossier: self,
        code_operation: 'I_BRAC',
        code_classe_evenement: 'LIQUIDATION',
        code_agence_liquidation: 'I_SG',
        numero_allocataire: numero_allocataire,
        nom: allocataire.nom,
        prenom: allocataire.prenom,
        adresse: allocataire.adresse_rue,
        mode_paiement: allocataire.mode_paiement,
        code_banque_allocataire: allocataire.compte_bancaire_code_banque,
        numero_compte_allocataire: allocataire.rib,
        bank_id: allocataire.bank_id,
        bank_branch_id: allocataire.bank_branch_id,
        date_debut_periode: nil,
        date_fin_periode: nil,
        montant: montant_revision_total,
        code_devise: 'XOF',
        statut: :en_cours,
        ordre_paiement: op,
        description: "Révision pension allocataire : #{numero_allocataire}",
      )
    end
  end

  def can_return_back?
    (self.soumis? and User.current.chef_section_instruction?) or
      (self.instruit? and User.current == self.affectation_salarie) or
      (self.carriere_soumis? and User.current.chef_service_cotisation?) or
      (self.cotisation_valide? and User.current == self.affectation_allocataire) or
      (self.recap_soumis? and User.current.chef_section_liquidation?) or
      (self.liquidation_valide? and User.current.chef_service_allocation?) or
      (self.valider? and User.current.directeur_prestation?) or
      (self.valider_directeur? and User.current.inspection?)
  end

  private

  def create_allocataire_suivi!
    if valider_revision?
      AllocataireSuiviModification.create(allocataire: self.allocataire,
                                          commentaire: "Revision Pension numero dossier #{self.numero_dossier} ##{self.id}",
                                          date_validation: DateTime.now,
                                          dossier_revision: self,
                                          impacte_montant_paiement: true)
    end
  end

  def set_numero_dossier
    annee = Date.today.year
    prefixe = 'R'
    if RevisionPension.exists?(numero_allocataire: numero_allocataire, type_motif: type_motif, created_at: (DateTime.now.beginning_of_year..DateTime.now.end_of_year))
      dernier_dossier_ajoute = RevisionPension.where(
          numero_allocataire: numero_allocataire,
          type_motif: type_motif,
          created_at: (DateTime.now.beginning_of_year..DateTime.now.end_of_year)
      ).order('created_at DESC').first
      self.numero_dossier = dernier_dossier_ajoute.numero_dossier.next
    else
      self.numero_dossier = "#{prefixe}/#{numero_allocataire}/#{annee}/01"
    end
  end

  def validate_date!
    return if date_reception.nil?

    if date_reception > Date.today
      errors.add(:date_reception, "Ne peut pas être postérieure à la date du jour (#{I18n.l(Date.today)})")
    end
  end
end
