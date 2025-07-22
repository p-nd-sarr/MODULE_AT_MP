class DossierJuridique < ApplicationRecord

  include WorkflowActiverecord
  include Documentable

  workflow_column :workflow_state

  workflow do
    state :creation, :meta => { label: 'Création' } do
      event :est_affecte, transition_to: :affectation
    end

    state :affectation, :meta => { label: 'Affectation' } do
      event :est_soumis, transition_to: :soumission
      event :retour_creation, transition_to: :creation
    end

    state :soumission, :meta => { label: 'Soumission' } do
      event :est_cloture, transition_to: :cloturation
      event :retour_affectation, transition_to: :affectation
    end

    state :cloturation, :meta => { label: 'Cloturation' }

  end

  validates :admin_type_dossier_juridique_id, presence: true

  has_many :affectation_dossier_juridiques, foreign_key: :dossier_juridiques_id
  has_many :avocats_huissiers, foreign_key: :dossier_juridique_id
  has_many :dossier_juridique_honoraires, foreign_key: :dossier_juridique_id
  has_many :dossier_juridique_actes, foreign_key: :dossier_juridique_id

  belongs_to :ajoute_par, class_name: 'User', foreign_key: :ajoute_par_id
  belongs_to :soumis_par, class_name: 'User', foreign_key: :soumis_par_id, optional: true
  belongs_to :cloture_par, class_name: 'User', foreign_key: :cloture_par_id, optional: true
  belongs_to :rejete_par, class_name: 'User', foreign_key: :rejete_par_id, optional: true
  belongs_to :admin_type_dossier_juridique, class_name: 'Admin::TypeDossierJuridique', foreign_key: :admin_type_dossier_juridique_id

  before_create :set_numero_dossier!

  def set_as_agent_chosen(id)
    dossier_affactation = AffectationDossierJuridique.new
    dossier_affactation.affecte_par = User.current
    dossier_affactation.affecte_a_id = id
    dossier_affactation.date_affectation = Date.today
    dossier_affactation.dossier_juridiques_id = self.id
    dossier_affactation.save
    puts 'error', dossier_affactation.errors.full_messages unless dossier_affactation.save
  end

  def is_not_agent_chosen_anymore(id)
    dossier_affactation = AffectationDossierJuridique.where(dossier_juridiques_id: self.id, affecte_a_id: id).first
    dossier_affactation.destroy
  end

  def is_set_manager(id)
    AffectationDossierJuridique.exists?(dossier_juridiques_id: self.id, affecte_a_id: id)
  end

  def set_numero_dossier!
    annee = Date.today.year
    if DossierJuridique.exists?(created_at: (DateTime.now.beginning_of_year..DateTime.now.end_of_year))
      dernier_dossier_ajoute = DossierJuridique.where(created_at: (DateTime.now.beginning_of_year..DateTime.now.end_of_year)).order('created_at DESC').first
      self.num_dossier = dernier_dossier_ajoute.num_dossier.next
    else
      self.num_dossier = "#{annee}/DOSSJU0001"
    end
  end

  def est_contrat?
    Admin::TypeDossierJuridique.find(self.admin_type_dossier_juridique_id).title == 'Contrat'
  end

  def get_honoraires(list_h)
    montant = 0
    list_h.each do |h|
      montant += h.montant
    end
    montant
  end

end
