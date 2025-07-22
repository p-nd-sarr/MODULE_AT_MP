class Psrm::Employeur < ApplicationRecord
  self.table_name = 'psrm_employeurs'
  has_many :bordereau_collectifs
  has_many :carriere_dossier_prestations, foreign_key: :num_employeur, primary_key: :fhnum
  has_many :mandataires, :class_name => 'Admin::Mandataire', foreign_key: :numero_employeur
  has_many :psrm_participants, :class_name => 'Psrm::Participant', foreign_key: :id_employeur, primary_key: :fhnum
  has_many :missing_declarations, class_name: 'MissingDeclaration', foreign_key: :numero_ipres, primary_key: :ancien_num_ipres
  has_many :declaration_salaire_manquantes, foreign_key: :numero, primary_key: :ancien_num_ipres
  has_many :dossier_prestations, foreign_key: :employeur_actuel, primary_key: :fhnum
  has_many :dossier_prestation_historics, foreign_key: :employeur_matric
  has_many :at_vente_carnets, primary_key: :fhnum, foreign_key: :num_employeur

  scope :with_carrieres_dp, -> { where(fhnum: CarriereDossierPrestation.pluck(:num_employeur)) }
  #scope :when_eligible, -> { joins(carriere_dossier_prestations: [dossier_prestation: :participant]).group('psrm_employeurs.id').having('count( distinct psrm_participants.matric) >= 5') }
  scope :when_eligible, -> { joins([dossier_prestations: :participant]).group('psrm_employeurs.id').having('count( distinct psrm_participants.matric) >= 5') }

  def has_bordereau?
    self.bordereau_collectifs.size > 0
  end

  def has_specific_bordereau(trimestre, annee)
    self.bordereau_collectifs.exists?(trimestre: trimestre, annee: annee)
  end

  def get_specific_bordereau(trimestre, annee)
    self.bordereau_collectifs.where(trimestre: trimestre, annee: annee).first
  end


=begin
  STATUT :
    * En cours Cessation
    * Actif
    * En cours Suspension
    * En attente reprise
    * Suspendu
    * Inactif
=end
end