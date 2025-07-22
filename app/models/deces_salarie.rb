class DecesSalarie < ApplicationRecord
  has_one_attached :certificat_deces

  validates :certificat_deces, content_type: { in: 'application/pdf', message: "n'est pas un PDF" }

  validates :numero_affiliation, :prenom, :nom, :date_deces, :numero_piece, presence: true

  validate :validate_numero_affiliation

  validate :validate_existence

  validate :validate_date_deces

  after_create :update_status_in_salary_table

  after_save :initiate_service_keeping

  after_destroy :close_service_keeping

  before_update :close_service_keeping

  def validate_date_deces
    if date_deces? and date_deces >= Date.today
      errors.add(:base, " La date de déces doit être antérieur à la date du jour.")
    end
  end

  private

  def validate_numero_affiliation
    return if numero_affiliation.nil? or numero_affiliation.empty?
    errors.add(:numero_affiliation, "Ce numéro d'affiliation est introuvable") unless Psrm::Participant.where(matric: numero_affiliation).exists? #or Allocataire.where(numero_allocataire: numero_affiliation).exists?
  end

  def validate_existence
    errors.add(:numero_affiliation, "Le décès a déjà été enregistré") if DecesSalarie.where(numero_affiliation: numero_affiliation).where.not(id: id).exists?
    errors.add(:numero_piece, "Le décès d'un salarié ayant un numéro de pièce identique a déjà été enregistré") if DecesSalarie.where(numero_piece: numero_piece).where.not(id: id).exists?
  end

  def update_status_in_salary_table
    salarie = Salarie.find_by(matric: self.numero_affiliation)
    return if salarie.nil?
    salarie.etat = :deces
    salarie.date_deces = date_deces
    salarie.save
  end

  def initiate_service_keeping
    salarie = Salarie.find_by(matric: self.numero_affiliation)
    dossier_prestation = DossierPrestation.where(conjoint_id: nil, num_affiliation: self.numero_affiliation).first
    return if dossier_prestation.nil?
    @maintien_prestation = MaintienPrestation.new
    @maintien_prestation.dossier_prestation = dossier_prestation
    @maintien_prestation.type_maintien = MaintienPrestation.type_maintiens[:deces]
    @maintien_prestation.commentaire = 'Maintien des prestations suité au décès du salarié'
    @maintien_prestation.date_effective = self.date_deces
    @maintien_prestation.date_demande_maintien = Date.today
    @maintien_prestation.date_arret_maintien = dossier_prestation.get_date_arret_maintien(@maintien_prestation)
    if @maintien_prestation.save
      if dossier_prestation.valide?
        dossier_prestation.est_suspendu!
        dossier_prestation.suspandu_par = User.current
        dossier_prestation.date_suspension = Date.today
        dossier_prestation.save
      end
    end
  end

  def close_service_keeping
    salarie = Salarie.find_by(matric: self.numero_affiliation)
    dossier_prestation = DossierPrestation.where(conjoint_id: nil, num_affiliation: self.numero_affiliation).first
    return if dossier_prestation.nil?
    if dossier_prestation.has_maintien_prestation_active?
      if dossier_prestation.get_maintien_prestations_active.deces?
        dossier_prestation.get_maintien_prestations_active.destroy
        if dossier_prestation.suspendu?
          dossier_prestation.retour_valides!
        end
      end
    end

  end

end
