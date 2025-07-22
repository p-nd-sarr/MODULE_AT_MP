class DossierJuridiqueHonoraire < ApplicationRecord

  TYPE_INTERVENANT = {
    avocat: 0,
    huissier: 1
  }
  enum type_intervenant: TYPE_INTERVENANT

  has_one_attached :document_justificatif

  belongs_to :dossier_juridique, foreign_key: :dossier_juridique_id
  belongs_to :avocats_huissier, foreign_key: :avocats_huissier_id, optional: true
  belongs_to :ajoute_par, class_name: 'User', foreign_key: :ajoute_par_id, optional: true

  validates :dossier_juridique_id, :date_eff, :montant, presence: true
  validates :document_justificatif, content_type: { in: 'application/pdf', message: "n'est pas un PDF" }, attached: true

  def is_selected(index)
    selectIndex = ''
    if self.nom_complet_juge != '' and index === 1
      selectIndex = 'selected'
    end
    unless self.avocats_huissier_id.nil?
      if self.avocats_huissier.avocat? and index === 2
        selectIndex = 'selected'
      end
      if self.avocats_huissier.huissier? and index === 3
        selectIndex = 'selected'
      end
    end
    selectIndex
  end

end
