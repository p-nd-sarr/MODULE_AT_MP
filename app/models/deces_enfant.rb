class DecesEnfant < ApplicationRecord
    TYPE_PIECE = {
      certificat_deces: 1
    }.freeze

    enum type_piece: TYPE_PIECE

    belongs_to :enfant

    has_one_attached :justificatif_deces

    validates :justificatif_deces, attached: true, content_type: {in: 'application/pdf', message: "n'est pas un PDF"}

    validate :validate_numero_affiliation

    validate :valider_date_deces

    validates :numero_affiliation, :enfant_id, :date_deces, presence: true

    after_save :update_status_child_in_child
    after_destroy :set_child_status_after_destroyed

    def full_name
      "#{prenom} #{nom}"
    end

    def valider_date_deces
      if date_deces? and date_deces > Date.today.to_date
        errors.add(:date_deces, "La date de déclaration ne peut être postérieur à la date du jour. ")
      end
    end

    def update_status_child_in_child
      self.enfant.update_columns(etat: :deces, date_deces: self.date_deces)
    end

    def set_child_status_after_destroyed
      self.enfant.update_columns(etat: :valide, date_deces: nil)
    end

    private

    def validate_numero_affiliation
      return if numero_affiliation.nil? or numero_affiliation.empty?
      errors.add(:numero_affiliation, "Ce numéro d'affiliation est introuvable") unless Psrm::Participant.where(matric: numero_affiliation).exists? #or Allocataire.where(numero_allocataire: numero_affiliation).exists?
    end

end
