class OrdrePaiement < ApplicationRecord
  STATUT = {
    en_attente_validation: -1,
    en_cours: 0,
    paye: 1,
    impaye: 2,
    regularise: 3,
    marque_impaye: 4
  }.freeze

  TYPE_BENEFICIARY = {
    conjoint: 1,
    attributaire: 2,
    caf_conjoint: 3
  }.freeze

  enum statut: STATUT
  enum type_beneficiary: TYPE_BENEFICIARY

  belongs_to :dossier, polymorphic: true, optional: true
  belongs_to :echeance_paiement, optional: true
  belongs_to :regularisation_pointage, class_name: 'Enrolement::RegularisationPointage', foreign_key: :regularisation_pointage_id, optional: true
  belongs_to :allocataire,
             foreign_key: :numero_allocataire,
             primary_key: :numero_allocataire,
             optional: true
  belongs_to :participant, :class_name => 'Psrm::Participant', foreign_key: :numero_allocataire, primary_key: :matric, optional: true
  belongs_to :prestation_exterieure, :class_name => 'PrestationExterieure', foreign_key: :numero_allocataire, primary_key: :numero_secu_social, optional: true
  belongs_to :impaye_ajoute_par, class_name: 'User', foreign_key: :impaye_ajoute_par_id, optional: true
  belongs_to :paye_par, class_name: 'User', foreign_key: :paye_par_id, optional: true
  belongs_to :impaye_par, class_name: 'User', foreign_key: :impaye_par_id, optional: true
  belongs_to :regularise_par, class_name: 'User', foreign_key: :regularise_par_id, optional: true
  belongs_to :ordre_paiement_regularise, class_name: 'OrdrePaiement', foreign_key: :ordre_paiement_regularise_id,
             optional: true
  belongs_to :beneficiaire, polymorphic: true, foreign_key: :beneficiaire_id, optional: true
  belongs_to :echeance_caisse_lot_liquidation, class_name: 'EcheanceCaisseLotLiquidation', foreign_key: :echeance_caisse_lot_liquidation_id, optional: true
  belongs_to :echeance_veuves_caisse_lot_liquidation, class_name: 'EcheanceVeuvesCaisseLotLiquidation', foreign_key: :echeance_veuves_caisse_lot_liquidation_id, optional: true

  has_many :compta_transactions

  has_many :allocation_prenatales
  has_many :allocation_postnatales
  has_many :allocation_familiales
  has_many :indemnite_conges_maternites
  has_many :indemnites_prestation_exterieure_assocs, foreign_key: :ordre_paiement_id
  has_one :ligne_pf_avis_tier_transaction, foreign_key: :ordre_paiements_id
  has_one :ligne_icm_avis_tiers_transaction, foreign_key: :ordre_paiements_id

  scope :marques_impayes, -> { where(statut: [:marque_impaye]) }
  scope :css, -> { where(dossier_type: %w[DossierPrestation DossierMaternite EcheanceCaisseLotLiquidation IndemniteCongesMaternite PrestationExterieure ArretTravail]) }
  scope :payes, -> { where(statut: [:paye]) }
  scope :payes_encours, -> { where(statut: [:paye, :en_cours]) }

  before_create :set_numero
  after_save :reinitialize_operation

  validates :numero, uniqueness: true

  def before_one_month_after_alloc_death
    ech = self.echeance_paiement
    death_date = self.allocataire.date_eteint
    date_ech = Date.new(ech.annee, ech.numero_periode, 1)

    return if death_date.nil?

    date_ech < death_date.next_month.end_of_month
  end

  def numero_format
    numero.format_with_space(4, 2, 2, 3, 3, 3)
  end

  def montant
    compta_transactions.sum(:montant)
  end

  def self.set_last_number(date_str)
    key = "ordre_paiement:dernier_numero_ordre:#{date_str}"
    unless $redis.exists?(key)
      dernier_numero = OrdrePaiement.where("numero LIKE ?", "#{date_str}%").maximum(:numero)
      dernier_numero = dernier_numero.nil? ? (ENV['INIT_NUMERO_ORDRE'] || 0).to_i : dernier_numero.last(9).to_i

      ttl = (2 * 24 * 60 * 60).to_i
      $redis.setex(key, ttl, dernier_numero)
    end
  end

  # @param [User] user
  def marquer_impaye(user, motif)
    return unless self.paye? or self.en_cours?
    self.statut = :marque_impaye
    self.impaye_ajoute_le = DateTime.now
    self.impaye_ajoute_par = user
    self.motif_impaye = motif
    self.save
    self.compta_transactions.update_all(statut: :marque_impaye)
    true
  end

  # @param [User] user
  def rendre_impaye(user)
    return unless self.marque_impaye?
    self.statut = :impaye
    self.impaye_le = DateTime.now
    self.impaye_par = user
    self.save
    self.compta_transactions.update_all(statut: :impaye)
    true
  end

  # @param [User] user
  def annuler_impaye
    return false unless self.marque_impaye?
    self.statut = :paye
    self.save
    self.compta_transactions.update_all(statut: :paye)
    true
  end

  def reinitialize_operation
    return unless self.impaye?
    if dossier_type == 'DossierPrestation' or dossier_type == 'DossierMaternite'
      compta_transactions.each do |cpt|
        cpt.dossier.update(paiement: false, ordre_paiement_id: nil, traite_par_id: nil)
      end
    elsif dossier_type == 'ArretTravail'
      compta_transactions.each do |cpt|
        cpt.dossier.update(paiement: false, ordre_paiement_id: nil, validation_comptable_par: nil, etat: 5)
      end
    elsif dossier_type == 'PrestationExterieure'
      # Sélectionner les indemnités associées à partir des dossiers
      indemnities_assoc = IndemnitesPrestationExterieureAssoc.where(id: compta_transactions.select(:dossier_id))

      # Supprimer les associations
      indemnities_assoc.destroy_all

      # Mettre à jour les indemnités si elles n'ont plus d'associations
      prestation_exterieure.indemnites_prestation_exterieures.each do |indemnity|
        if indemnity.indemnites_prestation_exterieure_assocs.empty?
          indemnity.destroy!
        else
          indemnity.update!(montant: indemnity.get_solde)
        end
      end
    elsif dossier_type == 'EcheanceCaisseLotLiquidation'
      ech_lot = EcheanceCaisseLotLiquidation.find(self.dossier_id)
      ech_emp = EcheanceCaisseEmployeur.find(ech_lot.echeance_caisse_employeur_id)
      EcheanceCaisseEnfant.where(id: ech_lot.echeance_caisse_liquidations.pluck(:echeance_caisse_enfant_id)).update_all(liquide: false)
      ech_emp.echeance_caisse_dossiers.each do |dossier|
        dossier.echeance_caisse_enfants.where(liquide: false, payable: false).each do |enfant|
          if (not dossier.time_of_presence_under_limit?(enfant.mois) and not dossier.is_retired_salary?(enfant.mois)) or (dossier.time_of_presence_under_limit?(enfant.mois) and dossier.is_retired_salary_for_month?(enfant.mois))
            enfant.update(payable: true)
          end
        end
      end
      EcheanceCaisseLiquidation.where(echeance_caisse_lot_liquidation_id: ech_lot.id).destroy_all
      AllocationFamiliale.where(echeance_caisse_lot_liquidation_id: ech_lot.id, is_from_ech_paid: false).destroy_all
      CarriereDossierPrestation.where(echeance_caisse_lot_liquidation_id: ech_lot.id).destroy_all
      ech_lot.destroy
      if ech_emp.echeance_caisse_lot_liquidations.empty?
        ech_emp.workflow_state = 'temps_presence_valide'
        ech_emp.save
      end
    end
    true
  end

  # @param [User] user
  def regulariser(user)
    return false unless self.impaye?
    ActiveRecord::Base.transaction do
      self.statut = :regularise
      self.regularise_le = DateTime.now
      self.regularise_par = user
      self.save
      self.compta_transactions.update_all(statut: :regularise)

      op = OrdrePaiement.create(ordre_paiement_regularise: self,
                                # echeance_paiement: self.echeance_paiement,
                                dossier: self.dossier,
                                numero_allocataire: self.numero_allocataire,
                                statut: :en_cours)

      ct = compta_transactions.first

      ComptaTransaction.create(
        ordre_paiement: op,
        # echeance_paiement: self.echeance_paiement,
        dossier: allocataire,
        code_operation: (ct.date_comptable || ct.created_at).year == Date.today.year ? 'I_BRAC' : 'I_BRAA',
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
        montant: montant,
        code_devise: 'XOF',
        statut: :en_cours,
        description: "Regularisation ordre #{numero_format}",
        admin_agence: allocataire.admin_agence,
        nin_allocataire: allocataire.numero_identification_nationale,
        telephone_allocataire: allocataire.telephone,
        mail_allocataire: allocataire.email,
        date_comptable: Date.today,
        admin_region: allocataire.admin_region,
        zone: allocataire.zone,

        infos_paiement_id_bhs: allocataire.infos_paiement_id_bhs,
        infos_paiement_id_ccp: allocataire.infos_paiement_id_ccp,
        infos_paiement_libelle_ccp: allocataire.infos_paiement_libelle_ccp,
        infos_paiement_succursale_cncas: allocataire.infos_paiement_succursale_cncas,
      )
    end

    # self.compta_transactions.each { |ct|
    #   c = ct.dup
    #   c.ordre_paiement = op
    #   c.code_operation = (ct.date_comptable || ct.created_at).year == Date.today.year ? 'I_BRAC' : 'I_BRAA'
    #   c.date_comptable = Date.today
    #   c.est_repris = false
    #   c.send_to_compta = false
    #   c.can_send_to_compta = true
    #   c.statut = :en_cours
    #   c.created_at = nil
    #   c.updated_at = nil
    #   c.save
    # }
    true
  end

  def generate_caisse_paiement
    ActiveRecord::Base.transaction do
      mode_paiement = compta_transactions.first.try(:mode_paiement)

      Caisse::Paiement.create(
        numero_ordre: numero,
        numero_allocataire: numero_allocataire,
        ipres_ancien_matric: allocataire.try(:ipres_ancien_matric),
        prenom: allocataire.try(:prenom),
        nom: allocataire.try(:nom),
        source: :prestation,
        mode_paiement: mode_paiement,
        details: compta_transactions.map { |compta_transaction| "#{compta_transaction.description} : #{compta_transaction.montant.to_i}" }.join("\n"),
        montant: montant,
        etat: :attente_paiement,
        annee: echeance_paiement.try(:annee) || self.created_at.year,
        periode: echeance_paiement.try(:periode) || :immediate,
        numero_periode: echeance_paiement.try(:numero_periode),
        echeance_paiement_id: echeance_paiement.try(:id),
        compta_transaction_id: nil,
      )

      self.send_to_caisse_paiement = true
      self.update_columns(send_to_caisse_paiement: true)
    end
  end

  private

  def set_numero
    #2021 02 10 000 000 001
    date_str = (est_repris? ? created_at : Date.today).strftime('%Y%m%d')
    n = OrdrePaiement.get_next_number(date_str)

    self.numero = date_str + "00000000#{n}".last(9)
  end

  def self.get_next_number(date_str)
    key = "ordre_paiement:dernier_numero_ordre:#{date_str}"

    OrdrePaiement.set_last_number(date_str) unless $redis.exists?(key)

    $redis.incr(key)
  end
end
