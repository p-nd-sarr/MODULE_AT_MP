class DemandeCarteAllocataire < ApplicationRecord
  belongs_to :user
  belongs_to :allocataire

  belongs_to :agence_enregistrement, :class_name => 'Admin::Agence', foreign_key: :agence_enregistrement_id, optional: true
  belongs_to :agence_retrait, :class_name => 'Admin::Agence', foreign_key: :agence_retrait_id, optional: true

  validates :prenom, :nom, :date_naissance, :nin, :telephone, :adresse,
            presence: true

  has_one_attached :document_cni
  has_one_attached :photo

  before_create :set_numero_document

  def set_numero_document
    return if self.numero_document.present?

    numero = SecureRandom.alphanumeric(6).upcase
    if DemandeCarteAllocataire.exists?(numero_document: numero)
      set_numero_document
    end
    self.numero_document = numero
  end
end
