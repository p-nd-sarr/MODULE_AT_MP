class Enrolement::RegularisationPointage < ApplicationRecord
  belongs_to :traite_par, class_name: 'User', foreign_key: 'traite_par_id', optional: true
  has_many :lignes, :class_name => 'Enrolement::RegularisationPointageLigne', foreign_key: 'enrolement_regularisation_pointage_id', dependent: :destroy
  has_many :allocataires, through: :lignes
  has_many :ordre_paiements, class_name: 'OrdrePaiement', foreign_key: 'regularisation_pointage_id'
  has_many :compta_transactions, through: :ordre_paiements

  validate :peut_etre_cree, on: :create

  after_create :generate_lignes

  include WorkflowActiverecord

  InvalidTransitionError = Class.new(StandardError)

  workflow_column :workflow_state

  workflow do
    state :creation, meta: { label: 'Création' } do
      event :valider, transition_to: :valide
      event :rejeter, transition_to: :rejete
    end

    state :valide, meta: { label: 'Validé' } do
      event :comptabiliser, transition_to: :comptabilise
    end

    state :comptabilise, meta: { label: 'Comptabilisé' }
    state :rejete, meta: { label: 'Rejeté' }
  end

  # @param [User] user
  def peut_valider?(user)
    user.admin?
  end

  # @param [User] user
  def peut_rejeter?(user)
    user.admin?
  end

  # @param [User] user
  def valider(user)
    halt!('Vous ne pouvez pas valider ce dossier') unless peut_valider?(user)
    ActiveRecord::Base.transaction do
      puts "validation par #{user.email}"
      self.traite_par = user
      self.traite_le = DateTime.now
      self.save!
    end
  end

  # @param [User] user
  def rejeter(user)
    halt!('Vous ne pouvez pas rejeter ce dossier') unless peut_rejeter?(user)
    ActiveRecord::Base.transaction do
      puts "rejet par #{user.email}"
      self.traite_par = user
      self.traite_le = DateTime.now
      self.save!
    end
  end

  # @param [User] user
  def comptabiliser
    ActiveRecord::Base.transaction do
      generate_paiements
    end
  end

  def generate_lignes
    puts "génération des lignes"
    return unless creation?
    ActiveRecord::Base.connection.execute(<<~SQL)
      INSERT INTO enrolement_regularisation_pointage_lignes (
        enrolement_regularisation_pointage_id,
        allocataire_id,
        numero_allocataire,
        source,
        pointage_id,
        source_matching,
        pres_prenom,
        pres_nom,
        pres_date_naissance,
        enr_prenom,
        enr_nom,
        enr_date_naissance,
        created_at,
        updated_at
      )
      (
        SELECT 
          #{self.id},
          a.allocataire_id,
          a.numero_allocataire,
          a.source,
          a.pointage_id,
          a.source_matching,
          a.pres_prenom,
          a.pres_nom,
          a.pres_date_naissance,
          a.enr_prenom,
          a.enr_nom,
          a.enr_date_naissance,
          NOW(),
          NOW()
        FROM pointage.allocataires_found a
        WHERE a.allocataire_id not in (
          SELECT allocataire_id FROM enrolement_regularisation_pointage_lignes
          INNER JOIN enrolement_regularisation_pointages ON enrolement_regularisation_pointages.id = enrolement_regularisation_pointage_lignes.enrolement_regularisation_pointage_id
          WHERE enrolement_regularisation_pointages.workflow_state <> 'rejete'
        )
      )
    SQL
  end

  def generate_paiements
    Admin::BaremePension.set_valeur_point_mensuelle_rg
    Admin::BaremePension.set_valeur_point_mensuelle_rc

    OrdrePaiement.set_last_number(Date.today.strftime('%Y%m%d'))
    OrdrePaiement.set_last_number(Date.tomorrow.strftime('%Y%m%d'))

    nb = lignes.where.not(supprime: true).count
    i = 0
    lignes.where.not(supprime: true).each do |ligne|
      puts "#{(100.0 * i / nb).ceil(2)} %"
      GeneratePaiementLigneRegulPointageJob.perform_later(ligne)
      i += 1
      puts "#{(100.0 * i / nb).ceil(2)} %"
    end

    # cotisation association allocataire
    # Admin::AssociationAllocataire.all.each { |association|
    #   nb_factures = allocataires.where(admin_association_allocataire_id: association.id).map{|a| a.echeances_manquantes.count }.sum
    #   # nb_allocataires = allocataires.where(admin_association_allocataire_id: association.id).count
    #   op = OrdrePaiement.create(regularisation_pointage: self,
    #                             dossier: association)
    #   ComptaTransaction.create(
    #     ordre_paiement: op,
    #     dossier: association,
    #     code_operation: 'I_RETASSRET',
    #     code_classe_evenement: 'ECHEANCE',
    #     code_agence_liquidation: 'I_SG',
    #     numero_allocataire: association.name,
    #     date_debut_periode: nil,
    #     date_fin_periode: nil,
    #     montant: 100 * nb_factures,
    #     code_devise: 'XOF',
    #     description: "Régularisation Cotisation association #{association.name}",
    #     can_send_to_compta: true,
    #   )
    # }
  end

  private

  def peut_etre_cree
    errors.add(:base, "Une régularisation de pointage est déjà en cours ...") if self.class.exists?(workflow_state: [:creation, :valide])
  end
end
