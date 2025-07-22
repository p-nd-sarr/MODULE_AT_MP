class Document < ApplicationRecord
  TYPE_DOCUMENT = {
    cni: 1,
    extrait_naissance: 2,
    attestation_travail: 3,
    certificat_mariage: 4,
    certificat_divorce: 5,
    cni_epouse: 6,
    extrait_naissance_epouse: 7,
    passeport: 8,
    carte_consulaire: 9,
    rib: 10,
    certificat_deces: 11,
    certificat_travail: 12,
    certificat_emploi_salaire: 13,
    certificat_non_divorce: 14,
    certificat_non_remariage: 15,
    extrait_naissance_defunt: 16,
    copie_cni_legalise: 17,
    attestation_non_engagement: 18,
    certificat_medical: 19,
    declaration_sur_honneur: 20,
    copie_cni: 21,
    acte_etat_civil_jug_supp_veuve: 22,
    jug_here_cert_non_opp_non_app: 23,
    carte_identite_tuteur: 24,
    certificat_tutelle: 25,
    autorisation_sortir_pays: 26,
    certif_empl_sal: 27,
    demande_conges: 28,
    certificat_medicale_gross: 29,
    attestation_susp_act: 30,
    last_bul_salaire: 31,
    attestation_cess_paie: 32,
    attestation_salaire: 33,
    attestation_maintien_salaire: 34,
    certif_conges_maternite: 35,
    certificat_scolarite: 36,
    cni_attributaire: 37,
    passeport_attributaire: 38,
    carte_consulaire_attributaire: 39,
    type_piece_attributaire: 40,
    type_piece_demandeur: 41,
    certificat_medical_consolidation: 42,
    rapport_evaluation_medecin: 43,
    pv_enquete: 44,
    bulletin_salaire_precedent_accident: 45,
    bulletin_de_salaire_journalier: 46,
    contrat_travail: 48,
    rapport_de_mer: 49,
    demande_extension_garantie: 50,
    relation_ecrite_temoin: 51,
    bulletin_de_salaire: 53,
    ordre_de_mission: 54,
    #      contrat_travail: 55,
    pv_police_gendarmerie: 56,
    rapport_sortie_sapeurs_pompiers: 57,
    pv_huissiers: 58,
    certificat_genre_de_mort: 59,
    certificat_guerison: 60,

    certificat_vie_individuelle: 62,
    demande_reversion_orphelin: 63,
    demande_reversion_veuve: 64,
    extraits_naissance_enfant: 65,
    certificat_infirmite: 66,
    certificat_apprentissage: 67,
    formulaire_convention_france_senegal_CFS: 68,
    certificat_de_domile: 69,
    certificat_de_residence: 70,
    certificat_medical_genre_de_mort: 71,
    cni_extrait: 72,
    formulaire_declaration_at: 73,
    relation_ecrite_premiere_avisee: 74,
    questionnaire_trajet: 75,
    acte_naissance_enf_moins_21: 76,
    certificat_vie_collective_enf_moins_21: 77,
    formulaire_demande_pension: 78,
    certificat_medicale: 79,

    protocole_accord_branche: 80,
    certificat_vie_collectif: 81,
    certificat_charge_entretien: 82,
    attestation_administrative: 83,
    decision_engagement: 84,
    decision_radiation: 85,
    cni_extrait_enfant: 86,
    cni_extrait_ascendant: 87,
    accord_sur_ipp: 88,
    releve_navigation: 88,
    tableau_indicatif_marin: 89,
    formulaire_demande: 90,
    carte_identite_defunt: 91,
    justificatif_reversion: 92,
    actes_deces_coepouse: 93,
    certificat_travail_prolongation: 94,
    certificat_travail_rechute: 95,
    contre_expertise: 96,
    procuration_legalisee: 97,
    bulletin_salaire_precedent_rechute: 98,
    dmt: 99,
    formulaire_demande_pf: 100,
    certificat_jugement_heredite: 101,

    cni_defunt: 110,
    acte_etat_civil: 111,
    copie_carte_consulaire_ou_cni: 112,
    certificat_travail_sn: 113,
    certificat_travail_pays_etranger: 114,
    releve_compte: 115,
    certificat_deces_coepouse: 116,
    certificat_divorce_coepouse: 117,
    lettre_de_mission: 118,

    autres: 1000
  }.freeze

  enum type_document: TYPE_DOCUMENT

  belongs_to :documentable, polymorphic: true

  has_one_attached :document
  validates :document, attached: true, content_type: { in: 'application/pdf', message: "n'est pas un PDF" }
  validates :type_document, presence: true
  validate :validate_document_af
  validate :validate_document_icm
  after_create :set_date_expiration
  after_create :set_allocation_after_doc_created
  after_destroy :set_allocation_after_doc_destroyed

  scope :expired, ->(documentable) { where(documentable: documentable).order(created_at: :desc).group_by(&:type_document).transform_values { |x| x.first }.values.select { |x| not (x.date_expiration.nil?) and x.date_expiration < Date.today + 3.months } }

  def validate_document_af
    if certificat_scolarite? or certificat_medical? or certificat_infirmite? or certificat_apprentissage?
      if date_delivrance_piece.nil?
        errors.add(:date_delivrance_piece, "La date de délivrance est obligatoire pour cette pièce.")
        #elsif date_expiration.nil?
        #errors.add(:date_expiration, "La d'expiration est obligatoire pour cette pièce.")
      elsif date_delivrance_piece > Date.today.to_date
        errors.add(:date_delivrance_piece, "La date de délivrance ne doit pas être postérieur à la date du jour.")
        #elsif date_expiration > date_delivrance_piece + 1.year
        # errors.add(:date_expiration, "La date de d'expiration ne doit pas être supérieur à un an.")
      end
    end
  end

  def set_date_expiration
    if certificat_medical? || certificat_infirmite?
      month_expire = 12 - date_delivrance_piece.month
      self.date_expiration = (date_delivrance_piece + month_expire.month).end_of_month
    elsif certificat_scolarite? || certificat_apprentissage?
      if date_delivrance_piece.month < 10
        month_expire = 9 - date_delivrance_piece.month
        self.date_expiration = (date_delivrance_piece + month_expire.month).end_of_month
      elsif date_delivrance_piece.month > 9
        month_expire = 21 - date_delivrance_piece.month
        self.date_expiration = (date_delivrance_piece + month_expire.month).end_of_month
      end
    end

    if certificat_medical? and self.documentable.instance_of?(Enfant) and self.documentable.age == 13
      birthday = Date.new(Date.today.year, self.documentable.date_naissance.month, self.documentable.date_naissance.day)
      if birthday.between?(Date.today, date_expiration)
        self.date_expiration = birthday
      end
    end

    self.save
  end

  def validate_document_icm
    if attestation_salaire? or attestation_cess_paie? or demande_conges? or attestation_travail? or certificat_medicale_gross? or
      certif_conges_maternite? or bulletin_de_salaire? or cni_attributaire? or attestation_cess_paie? or attestation_maintien_salaire?
      unless date_expiration.nil? or date_delivrance_piece.nil?
        if date_expiration < date_delivrance_piece
          errors.add(:date_expiration, "La date d'expiration ne doit pas être antérieur à la date de délivrance")
        end
      end
    end
  end

  def set_allocation_after_doc_destroyed
    return unless self.documentable.instance_of?(Enfant)
    self.documentable.allocation_familiales.creation.each do |af|
      date_ref = Date.new(af.annee, af.read_attribute_before_type_cast(:trimestre) * 3, 1).end_of_month
      unless self.documentable.documents.where("date_expiration >= ?", date_ref).exists?
        if self.documentable.migrated_document_exp_date.nil? or (not self.documentable.migrated_document_exp_date.nil? and self.documentable.migrated_document_exp_date < date_ref)
          af.update(document_valid: false)
        end
      end
    end
    EcheanceCaisseEnfant.where(enfant_id: self.documentable.id, document_valide: true, liquide: false).each do |ech|
      date_ref = Date.new(ech.echeance_caisse.annee, ech.echeance_caisse.trimestre * 3, 1).end_of_month
      unless self.documentable.documents.where("date_expiration >= ?", date_ref).exists?
        if self.documentable.migrated_document_exp_date.nil? or (not self.documentable.migrated_document_exp_date.nil? and self.documentable.migrated_document_exp_date < date_ref)
          ech.update(document_valide: false)
        end
      end
    end
    EcheanceVeuvesCaisseEnfant.where(enfant_id: self.documentable.id, document_valide: true, liquide: false).each do |ech|
      date_ref = Date.new(ech.echeance_veuves_caisse.annee, ech.echeance_veuves_caisse.trimestre * 3, 1).end_of_month
      unless self.documentable.documents.where("date_expiration >= ?", date_ref).exists?
        if self.documentable.migrated_document_exp_date.nil? or (not self.documentable.migrated_document_exp_date.nil? and self.documentable.migrated_document_exp_date < date_ref)
          ech.update(document_valide: false)
        end
      end
    end
    # if certificat_scolarite? or certificat_medical?
    #   if self.documentable.instance_of?(Enfant) and self.documentable.migrated_document_exp_date?
    #     return if self.documentable.migrated_document_exp_date > Date.today
    #   end
    #   self.documentable.document_valid!(false) if self.documentable.documents.length === 0 and self.documentable.class.method_defined? :document_valid!
    #   ech_enfants = EcheanceCaisseEnfant.where(enfant_id: self.documentable.id, document_valide: true, liquide: false)
    #   ech_enfants.update_all(document_valide: false) if self.documentable.documents.length === 0
    #   ech_enfants = EcheanceVeuvesCaisseEnfant.where(enfant_id: self.documentable.id, document_valide: true, liquide: false)
    #   ech_enfants.update_all(document_valide: false) if self.documentable.documents.length === 0
    # end
  end

  def set_allocation_after_doc_created
    return unless self.documentable.instance_of?(Enfant)
    self.documentable.allocation_familiales.creation.each do |af|
      date_ref = Date.new(af.annee, af.read_attribute_before_type_cast(:trimestre) * 3, 1).end_of_month
      if self.date_expiration >= date_ref
        af.update(document_valid: true)
      end
    end
    EcheanceCaisseEnfant.where(enfant_id: self.documentable.id, document_valide: false, liquide: false).each do |ech|
      date_ref = Date.new(ech.echeance_caisse.annee, ech.echeance_caisse.trimestre * 3, 1).end_of_month
      if self.date_expiration >= date_ref
        ech.update(document_valide: true)
      end
    end
    EcheanceVeuvesCaisseEnfant.where(enfant_id: self.documentable.id, document_valide: false, liquide: false).each do |ech|
      date_ref = Date.new(ech.echeance_veuves_caisse.annee, ech.echeance_veuves_caisse.trimestre * 3, 1).end_of_month
      if self.date_expiration >= date_ref
        ech.update(document_valide: true)
      end
    end
    #self.documentable.allocation_familiales.creation.update_all(document_valid: true)
    #EcheanceCaisseEnfant.where(enfant_id: self.documentable.id, document_valide: false, liquide: false).update_all(document_valide: true)
    #EcheanceVeuvesCaisseEnfant.where(enfant_id: self.documentable.id, document_valide: false, liquide: false).update_all(document_valide: true)
  end

end
