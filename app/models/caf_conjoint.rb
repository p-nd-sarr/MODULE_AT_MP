class CafConjoint < ApplicationRecord

  SEXE = {
    inconnu: 0,
    masculin: 1,
    feminin: 2,
    sans_objet: 9
  }

  ETAT_COUPLE = {
    marie: 1,
    divorce: 2,
    decede: 3,
    non_marie: 5,
    not_defined1: 4
  }.freeze

  TYPE_PIECE = {
    cni: 1,
    carte_consulaire: 2,
    passeport: 3,
    not_defined2: 4
  }

  enum etat_couple: ETAT_COUPLE
  enum sexe: SEXE
  enum type_piece: TYPE_PIECE

  belongs_to :prestation_exterieure, class_name: 'PrestationExterieure', foreign_key: :prestation_exterieure_id, optional: true
  belongs_to :ajoute_par, class_name: 'User', foreign_key: :ajoute_par_id, optional: true

  has_one_attached :certificat_mariage
  has_one_attached :piece_identite
  has_one_attached :certificat_divorce
  has_one_attached :certificat_deces
  has_many :caf_enfants, dependent: :destroy
  has_many :ordre_paiements, as: :beneficiaire, foreign_type: "type_beneficiary", dependent: :destroy

  validates :nin_conjoint, uniqueness: true, on: :create
  validates :nin_conjoint, length: { in: 13..14 }, if: :cni?
  validate :valider_date_naissance_mariage
  validate :valider_date_separation
  validate :valider_date_divorce
  validate :valider_sexe_conjoint
  validate :valider_certificat_mariage
  validate :valider_certificat_divorce
  validate :valider_certificat_deces

  validates :certificat_mariage, content_type: { in: 'application/pdf', message: "n'est pas un PDF" }
  validates :certificat_mariage, content_type: { in: 'application/pdf', message: "n'est pas un PDF" }
  validates :piece_identite, content_type: { in: 'application/pdf', message: "n'est pas un PDF" } #, attached: true
  validates :certificat_divorce, content_type: { in: 'application/pdf', message: "n'est pas un PDF" } #, attached: true
  validates :certificat_deces, content_type: { in: 'application/pdf', message: "n'est pas un PDF" } #, attached: true

  after_update :remove_attachment_if_needed

  def remove_attachment_if_needed
    certificat_mariage.purge_later if non_marie? && certificat_mariage.attached?
    certificat_divorce.purge_later if non_marie? && certificat_divorce.attached?
    certificat_deces.purge_later if non_marie? && certificat_deces.attached?
  end

  def valider_certificat_mariage
    if marie?
      unless certificat_mariage.attached?
        errors.add(:base, "Vous devez joindre le certificat de mariage")
      end
    end
  end

  def valider_certificat_divorce
    if divorce?
      unless certificat_divorce.attached?
        errors.add(:base, "Vous devez joindre le certificat de divorce")
      end
    end
  end

  def valider_certificat_deces
    if decede?
      unless certificat_deces.attached?
        errors.add(:base, "Vous devez joindre le certificat de décès")
      end
    end
  end

  def montant_beneficiaire(id_conjoint, d_debut, d_fin)
    nb_month = (d_fin.month - d_debut.month) + 1
    nb_children = get_nombre_enfant(id_conjoint, d_debut, d_fin)
    barem = recursive_prev_year(d_fin.year).montant_indemnites
    montant = (barem * nb_children) * nb_month

=begin
    get_indemnities_by_conjoint(id_conjoint, d_debut, d_fin).each do |indemnity|
      montant += indemnity.montant
    end
=end

    montant
  end

  def get_montant_beneficiaire_net(id_conjoint, d_debut, d_fin)
    montant = montant_beneficiaire(id_conjoint, d_debut, d_fin)
    montant * 80 / 100
  end

  def get_nombre_enfant(id_conjoint, d_debut, d_fin)
    nombre = get_enfant(id_conjoint, d_debut, d_fin).count
  end

  def get_indemnities_by_conjoint(id_conjoint, d_debut, d_fin)
    IndemnitesPrestationExterieure.joins(indemnites_prestation_exterieure_assocs: [caf_enfant: :caf_conjoint]).where(caf_conjoints: { id: id_conjoint }).where(indemnites_prestation_exterieures: { workflow_state_dt: :droit_valide, date_debut: d_debut, date_fin: d_fin }).where(indemnites_prestation_exterieure_assocs: { caf_enfant_id: CafConjoint.find(id_conjoint).caf_enfants.pluck(:id) })
  end

  def get_enfant(id_conjoint, d_debut, d_fin)
    enfants = CafEnfant.joins([indemnites_prestation_exterieure_assocs: :indemnites_prestation_exterieure], :caf_conjoint).where(caf_conjoints: { id: id_conjoint }).where(indemnites_prestation_exterieures: { workflow_state_dt: :droit_valide, date_debut: d_debut, date_fin: d_fin })
  end

  def has_indemnities?
    IndemnitesPrestationExterieureAssoc.where(caf_enfant_id: caf_enfants.pluck(:id)).exists?
  end

  def full_name
    "#{prenom} #{nom_jeune_fille}"
  end

  def valider_date_naissance_mariage
    if self.date_mariage and self.date_naissance > self.date_mariage
      errors.add(:date_mariage, "la date de mariage ne peut être antérieur à la date de naissance")
    end
  end

  def valider_date_separation
    if self.date_separation? and self.date_mariage > self.date_separation
      errors.add(:date_separation, "la date de séparation ne peut être antérieur à la date de mariage")
    end
  end

  def valider_date_divorce
    if self.date_divorce? and self.date_mariage > self.date_divorce
      errors.add(:date_divorce, "la date de divorce ne peut être antérieur à la date de mariage")
    end
  end

  def valider_sexe_conjoint
    if self.sexe == prestation_exterieure.sexe_salarie
      errors.add(:sexe_salarie, "Le salarié et le conjoint ne peuvent pas être du même sexe")
    end
  end

  def is_beneficiary!
    update(is_beneficiary: true)
    self.prestation_exterieure.caf_conjoints.each do |conjoint|
      unless conjoint.id == self.id
        conjoint.update(is_beneficiary: false)
      end
    end

  end

  def is_not_beneficiary_anymore!
    update(is_beneficiary: false)
  end

  def recursive_prev_year(year)
    caf_barems = Admin::CafBareme.where('date_debut_validite <= ?', Date.new(year, 1, 1))
    if caf_barems.length == 0
      return
    end

    caf_bareme = Admin::CafBareme.where(date_debut_validite: Date.new(year, 1, 1)).last
    if caf_bareme.nil?
      return recursive_prev_year(year - 1)
    end

    caf_bareme
  end

end