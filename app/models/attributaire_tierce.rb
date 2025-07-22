class AttributaireTierce < ApplicationRecord
  include WorkflowActiverecord

  workflow_column :workflow_state
  workflow do
    state :creation, :meta => { label: 'Création' } do
      event :est_soumis, transition_to: :soumis
      event :est_cloture, transition_to: :cloture
    end

    state :soumis, :meta => { label: 'Soumis' } do
      event :est_valide, transition_to: :valide
      event :est_cloture, transition_to: :cloture
      event :est_rejete, transition_to: :rejete
    end

    state :valide, :meta => { label: 'Validé' } do
      event :est_cloture, transition_to: :cloture
    end

    state :rejete, :meta => { label: 'Rejeté' }
    state :cloture, :meta => { label: 'Cloturé' }
  end

  belongs_to :dossier_prestation
  belongs_to :ajoute_par, class_name: 'User', :foreign_key => :ajoute_par_id
  belongs_to :soumis_par, class_name: 'User', :foreign_key => :soumis_par_id, optional: true
  belongs_to :valide_par, class_name: 'User', :foreign_key => :valide_par_id, optional: true
  belongs_to :rejete_par, class_name: 'User', :foreign_key => :rejete_par_id, optional: true
  belongs_to :cloture_par, class_name: 'User', :foreign_key => :cloture_par_id, optional: true
  has_many :beneficiary_associations_to_dps
  has_many :ordre_paiements, as: :beneficiaire, dependent: :destroy

  validates :nin, presence: true, uniqueness: true
  validate :length_of_nin

  scope :est_valide, -> { where(workflow_state: [:valide]) }

  before_save :set_last_record

  def full_name
    "#{prenom} #{nom}"
  end

  def set_last_record
    if User.current.chef_agence? and valide?
      last_record = AttributaireTierce.where(workflow_state: :valide).first
      return if last_record.nil?
      if last_record.valide?
        last_record.est_cloture!
        last_record.cloture_par = User.current
        last_record.date_cloturation = Date.today
        last_record.save
      end
    end
  end

  def length_of_nin
    if nin
      unless nin.length.between?(13, 14)
        errors.add(:base, "la taille du nin doit être comprise entre 13 et 14 caractères!")
      end
    end
  end

  def numero_piece
    nin
  end
end
