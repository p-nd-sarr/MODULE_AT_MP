class EcheanceCaisseDossier < ApplicationRecord
  include WorkflowActiverecord

  default_scope { order('nom, prenom') }

  workflow_column :workflow_state

  workflow do
    state :creation, meta: { label: 'Création' } do
      event :diffuser, transition_to: :diffuse
    end

    state :diffuse, meta: { label: 'Diffusé' }
  end

  belongs_to :echeance_caisse
  belongs_to :dossier_prestation
  belongs_to :echeance_caisse_employeur
  has_many :echeance_caisse_enfants

  scope :not_individual, -> { where(is_individual_payment: false) }
  scope :with_beneficiaries_added, -> { joins(:echeance_caisse_employeur).where(dossier_prestation_id: BeneficiaryAssociationsToDp.pluck(:dossier_prestation_id)) }

  def has_beneficiaries?
    not is_individual_payment? and echeance_caisse_enfants.exists?(paiement_individuel: true)
  end

  def can_set_individual_payment?(user)
    user.gestionnaire_compte_allocataire? and not self.is_individual_payment? and self.echeance_caisse_enfants.where(liquide: false).count > 0
  end

  def can_remove_individual_payment?(user)
    user.gestionnaire_compte_allocataire? and self.is_individual_payment? and self.echeance_caisse_enfants.where(liquide: false).count > 0
  end

  def set_individual_payment_option
    self.echeance_caisse_enfants.where(liquide: false).update_all(paiement_individuel: true)
    self.is_individual_payment = true
    self.individual_payment_by = User.current.id
    self.save
  end

  def remove_individual_payment_option
    self.echeance_caisse_enfants.where(liquide: false).update_all(paiement_individuel: false)
    self.is_individual_payment = false
    self.individual_payment_by = nil
    self.save
  end

  def get_total_amount
    self.echeance_caisse_enfants.includes(:enfant).order('numero_ordre').where.not(id: get_excluded_months.pluck(:id)).limit(get_limit_of_children).pluck(:montant).sum()
  end

  def get_validated_amount
    self.echeance_caisse_enfants.includes(:enfant).where(document_valide: true).order('numero_ordre').where.not(id: get_excluded_months.pluck(:id)).limit(get_limit_of_children).pluck(:montant).sum()
  end

  def get_unvalidated_amount
    get_total_amount - get_validated_amount
  end

  def get_unpaid_amount
    get_validated_amount - get_amount_paid
  end

  def get_excluded_months
    echeance_caisse_enfants.joins(:echeance_caisse_dossier).where("echeance_caisse_enfants.mois = ? and echeance_caisse_dossiers.temps_presence_mois1 < ? and echeance_caisse_dossiers.absence_justifie_mois1 = ? and not (echeance_caisse_dossiers.date_naissance + INTERVAL '60 years' >= ? and echeance_caisse_dossiers.date_naissance + INTERVAL '60 years' < ?)", 1, 18, false, self.echeance_caisse.periode_debut, self.echeance_caisse.periode_debut + 1.months)
                           .or(echeance_caisse_enfants.joins(:echeance_caisse_dossier).where("echeance_caisse_enfants.mois = ? and echeance_caisse_dossiers.temps_presence_mois2 < ? and echeance_caisse_dossiers.absence_justifie_mois2 = ? and not (echeance_caisse_dossiers.date_naissance + INTERVAL '60 years' >= ? and echeance_caisse_dossiers.date_naissance + INTERVAL '60 years' < ?)", 2, 18, false, self.echeance_caisse.periode_debut + 1.month, self.echeance_caisse.periode_debut + 2.month))
                           .or(echeance_caisse_enfants.joins(:echeance_caisse_dossier).where("echeance_caisse_enfants.mois = ? and echeance_caisse_dossiers.temps_presence_mois3 < ? and echeance_caisse_dossiers.absence_justifie_mois3 = ? and not (echeance_caisse_dossiers.date_naissance + INTERVAL '60 years' >= ? and echeance_caisse_dossiers.date_naissance + INTERVAL '60 years' < ?)", 3, 18, false, self.echeance_caisse.periode_debut + 2.month, self.echeance_caisse.periode_debut + 3.month))

  end

  def get_limit_of_children
    excluded_ids = get_excluded_months.pluck(:id)

    enfants_par_mois = echeance_caisse_enfants
                         .where.not(id: excluded_ids)
                         .select(:id, :mois)
                         .group_by(&:mois)

    limit = enfants_par_mois.sum do |_mois, enfants|
      [enfants.count, 6].min
    end

    limit
  end

  def get_current_limit_of_children
    excluded_ids = get_excluded_months.pluck(:id)

    enfants_par_mois = echeance_caisse_enfants
                         .where.not(id: excluded_ids)
                         .select(:id, :mois)
                         .group_by(&:mois)

    # Récupérer les liquidations liquides pour optimiser les requêtes
    paid_liquidations = EcheanceCaisseLiquidation
                          .where(echeance_caisse_enfant_id: enfants_par_mois.values.flatten.map(&:id), liquide: true)
                          .group_by(&:echeance_caisse_enfant_id)

    limit = enfants_par_mois.sum do |_mois, enfants|
      paid_liq_count = enfants.count { |enfant| paid_liquidations.key?(enfant.id) }
      [enfants.count, 6 - paid_liq_count].min
    end

    limit
  end

  def get_excluded_months_by_child
    get_excluded_months.count / echeance_caisse_enfants.pluck(:enfant_id).uniq.count
  end

  def is_retired_salary_for_month?(month)
    (month == 1 and ((date_naissance + 60.years >= echeance_caisse.periode_debut) and (date_naissance + 60.years < echeance_caisse.periode_debut + 1.month)) or
      month == 2 and ((date_naissance + 60.years >= echeance_caisse.periode_debut + 1.month) and (date_naissance + 60.years < echeance_caisse.periode_debut + 2.month)) or
      month == 3 and ((date_naissance + 60.years >= echeance_caisse.periode_debut + 2.month) and (date_naissance + 60.years < echeance_caisse.periode_debut + 3.month))
    )
  end

  def is_retired_salary?(mois)
    end_date = Date.new(self.echeance_caisse.annee, self.echeance_caisse.trimestre * 3, 1).beginning_of_quarter + (mois - 1).months
    self.date_naissance + 60.years < end_date
  end

  def time_of_presence_under_limit?(month)
    ((month == 1 and temps_presence_mois1 < 18 and not absence_justifie_mois1?) or (month == 2 and temps_presence_mois2 < 18 and not absence_justifie_mois2?) or (month == 3 and temps_presence_mois3 < 18 and not absence_justifie_mois3?))
  end

  def check_if_child_can_be_paid(id, month)
    EcheanceCaisseEnfant.find(id).document_valide? and EcheanceCaisseEnfant.find(id).payable? and
      ((month == 1 and (temps_presence_mois1 >= 18 or absence_justifie_mois1? or is_retired_salary_for_month?(month))) or (month == 2 and (temps_presence_mois2 >= 18 or absence_justifie_mois2 or is_retired_salary_for_month?(month))) or (month == 3 and (temps_presence_mois3 >= 18 or absence_justifie_mois3? or is_retired_salary_for_month?(month))))
  end

  def is_paid?(id)
    EcheanceCaisseLiquidation.exists?(echeance_caisse_employeur_id: self.echeance_caisse_employeur_id, echeance_caisse_enfant_id: id, liquide: true)
  end

  def presence_mois1_valide?
    (not temps_presence_mois1; nil? and temps_presence_mois1 >= 18) or absence_justifie_mois1?
  end

  def presence_mois2_valide?
    (not temps_presence_mois2; nil? and temps_presence_mois2 >= 18) or absence_justifie_mois2?
  end

  def presence_mois3_valide?
    (not temps_presence_mois3; nil? and temps_presence_mois3 >= 18) or absence_justifie_mois3?
  end

  def get_amount_liquidated(echeance_liquidations)
    EcheanceCaisseEnfant.where(id: echeance_liquidations.pluck(:echeance_caisse_enfant_id), echeance_caisse_dossier_id: self.id).sum(:montant)
  end

  def get_amount_paid
    echeance_caisse_enfants.where(liquide: true).sum(:montant)
  end

  def can_exclude?
    User.current.gestionnaire_compte_allocataire? and not EcheanceCaisseLiquidation.exists?(echeance_caisse_enfant_id: echeance_caisse_enfants.pluck(:id))
  end

  def get_out_of_echeance
    return if EcheanceCaisseLiquidation.where(echeance_caisse_enfant_id: echeance_caisse_enfants.select(:id)).exists?

    h = HistoricEchExclusion.new(
      echeance_caisse: self.echeance_caisse,
      echeance_caisse_employeur: self.echeance_caisse_employeur,
      dossier_prestation: self.dossier_prestation,
      ajoute_par: User.current
    )

    ActiveRecord::Base.transaction do
      if h.save && echeance_caisse_enfants.destroy_all
        self.destroy
      else
        raise ActiveRecord::Rollback
      end
    end
  end

  def get_out_of_echeance_after_transfer
    return if EcheanceCaisseLiquidation.where(echeance_caisse_enfant_id: echeance_caisse_enfants.select(:id), liquide: true).exists?

    h = HistoricEchExclusion.new(
      echeance_caisse: self.echeance_caisse,
      echeance_caisse_employeur: self.echeance_caisse_employeur,
      dossier_prestation: self.dossier_prestation,
      ajoute_par: User.current
    )

    ActiveRecord::Base.transaction do
      if h.save
        EcheanceCaisseLiquidation.where(echeance_caisse_enfant_id: echeance_caisse_enfants.select(:id)).destroy_all
        if echeance_caisse_enfants.destroy_all
          self.destroy
        else
          raise ActiveRecord::Rollback
        end
      end
    end
  end

end
