class DeclarationChargement < ApplicationRecord
  STATUT = {
    creation: 0,
    fichier_invalide: 1,
    fichier_valide: 2,
    valide: 3,
    rejete: 4,
  }.freeze

  enum statut: STATUT

  REGIME = {
    general: 1,
    cadre: 2,
    employe_de_maison: 3
  }.freeze

  enum regime: REGIME

  belongs_to :declaration_salaire_manquante

  has_many :declaration_carrieres
  has_many :declaration_participants
  has_many :declaration_chargement_lignes
  belongs_to :created_by, class_name: 'User', foreign_key: :created_by_id, optional: true
  belongs_to :traite_par, class_name: 'User', foreign_key: :traite_par_id, optional: true

  has_one_attached :fichier
  validates :fichier, attached: true,
            content_type: {
              in: %w[application/vnd.openxmlformats-officedocument.spreadsheetml.sheet application/vnd.ms-excel],
              message: "n'est pas un fichier Excel"
            }

  validate :validate_en_tete
  validate :validate_statut, on: :create

  before_validation :set_values
  after_create :load_lignes, :check_lignes, :set_statut_declaration_manquante
  before_save :set_statut_declaration_manquante

  def load_lignes
    sheet = Roo::Spreadsheet.open(ActiveStorage::Blob.service.path_for(fichier.key), extension: fichier.filename.extension).sheet(0)

    (16..sheet.last_row - 1).each { |i|
      declaration_chargement_lignes.create(
        numero_ligne: i,
        exercice: sheet.cell(i, 2),
        numero_affiliation: sheet.cell(i, 3).nil? ? nil : sheet.cell(i, 3).to_s.gsub(".0", ''),
        nom: sheet.cell(i, 4),
        prenom: sheet.cell(i, 5),
        matricule_interne: sheet.cell(i, 6).nil? ? nil : sheet.cell(i, 6).to_s.gsub(".0", ''),
        jour_entree: sheet.cell(i, 7),
        mois_entree: sheet.cell(i, 8),
        annee_entree: sheet.cell(i, 9),
        jour_sortie: sheet.cell(i, 10),
        mois_sortie: sheet.cell(i, 11),
        annee_sortie: sheet.cell(i, 12),
        motif_sortie: sheet.cell(i, 13),
        salaire_soumis: sheet.cell(i, 14),
        salaire_reel: sheet.cell(i, 15),
        statut: sheet.cell(i, 16).nil? ? nil : sheet.cell(i, 16).to_s.gsub(".0", ''),
        nin: sheet.cell(i, 17).nil? ? nil : sheet.cell(i, 17).to_s.gsub(".0", ''),
        date_naissance: sheet.cell(i, 18),
        lieu_naissance: sheet.cell(i, 19),
        profession: sheet.cell(i, 20),
        nationalite: sheet.cell(i, 21),
        sexe: sheet.cell(i, 22).nil? ? nil : sheet.cell(i, 22).to_s[0],
      )
    }
  end

  def check_lignes
    declaration_chargement_lignes.update_all(details_erreur: [], erreur: nil)

    declaration_chargement_lignes.where("(numero_affiliation IS NULL or numero_affiliation = '0') and (nin IS NULL or nin = '0')").each do |ligne|
      ligne.erreur = true
      ligne.details_erreur << 'Le numéro d\'affiliation ou le NIN est obligatoire'
      ligne.save
    end

    declaration_chargement_lignes.where.not(exercice: declaration_salaire_manquante.exercice).each do |ligne|
      ligne.erreur = true
      ligne.details_erreur << "L'année ne correspond pas à l'exercice de la déclaration"
      ligne.save
    end

    doublons_numero_affiliation = declaration_chargement_lignes.where.not("numero_affiliation IS NULL or numero_affiliation = '0'").select('numero_affiliation').group(:numero_affiliation).having('count(numero_affiliation)>1').map(&:numero_affiliation)
    declaration_chargement_lignes.where(numero_affiliation: doublons_numero_affiliation).each do |ligne|
      ligne.erreur = true
      ligne.details_erreur << 'Le numéro d\'affiliation est en doublon'
      ligne.save
    end

    doublons_nin = declaration_chargement_lignes.where.not("nin IS NULL or nin = '0'").select('nin').group(:nin).having('count(nin)>1').map(&:nin)
    declaration_chargement_lignes.where(nin: doublons_nin).each do |ligne|
      ligne.erreur = true
      ligne.details_erreur << 'Le NIN est en doublon'
      ligne.save
    end

    declaration_chargement_lignes.where.not("numero_affiliation IS NULL or numero_affiliation = '0'").each do |ligne|
      unless Psrm::Participant.where("matric = ? or ipres_ancien_matric = ?", ligne.numero_affiliation.strip, ligne.numero_affiliation.strip).exists?
        ligne.erreur = true
        ligne.details_erreur << "Le salarié n'existe pas dans prestation"
        ligne.save
      end
    end

    declaration_chargement_lignes.where("nom IS NULL or nom = ''").each do |ligne|
      ligne.erreur = true
      ligne.details_erreur << 'Le nom est obligatoire'
      ligne.save
    end

    declaration_chargement_lignes.where("prenom IS NULL or prenom = ''").each do |ligne|
      ligne.erreur = true
      ligne.details_erreur << 'Le prénom est obligatoire'
      ligne.save
    end

    declaration_chargement_lignes.where("salaire_soumis IS NULL or salaire_soumis = 0").each do |ligne|
      ligne.erreur = true
      ligne.details_erreur << 'Le salaire soumis à cotisation est obligatoire'
      ligne.save
    end

    declaration_chargement_lignes.each do |ligne|
      begin
        ligne.date_entree
      rescue Date::Error
        ligne.erreur = true
        ligne.details_erreur << 'La date d\'entrée est invalide'
        ligne.save
      end

      begin
        ligne.date_sortie
      rescue Date::Error
        ligne.erreur = true
        ligne.details_erreur << 'La date de sortie est invalide'
        ligne.save
      end
    end

    if declaration_chargement_lignes.exists?(erreur: true)
      self.fichier_invalide!
    else
      self.fichier_valide!
    end

    declaration_chargement_lignes.where(erreur: nil).update_all(erreur: false)
  end

  def valider(user)
    if self.fichier_valide?
      ActiveRecord::Base.transaction do
        self.valide!
        self.traite_par = user
        self.traite_le = Time.now
        self.save

        self.load_salaries
        self.load_carrieres

        declaration_salaire_manquante.chargee!
      end
    end
  end

  def rejeter(user, motif=nil)
    if self.fichier_valide?
      ActiveRecord::Base.transaction do
        self.rejete!
        self.traite_par = user
        self.traite_le = Time.now
        self.motif_rejet = motif
        self.save
        declaration_salaire_manquante.manquante!
      end
    end
  end

  def load_salaries
    return unless valide?
    declaration_chargement_lignes.where(erreur: false).each { |ligne|
      declaration_participants.create(
        matric: (ligne.numero_affiliation.nil? or ['0', ''].include?(ligne.numero_affiliation)) ? ligne.nin.delete(' ') : ligne.numero_affiliation.delete(' '),
        ipres_ancien_matric: (ligne.numero_affiliation.nil? or ['0', ''].include?(ligne.numero_affiliation)) ? ligne.nin.delete(' ') : ligne.numero_affiliation.delete(' '),
        css_ancien_matric: nil,
        prenom: ligne.prenom&.strip,
        nom: ligne.nom&.strip,
        type_piece: 'CNI',
        numero_piece: ligne.nin&.strip,
        profession: ligne.profession&.strip,
        emploi: nil,
        regime: general? ? 'RG' : (cadre? ? 'RCC' : nil),
        addr: nil,
        phone: nil,
        date_naissance: ligne.date_naissance,
        genre: ligne.sexe&.strip == 'M' ? 'HOMME' : 'FEMME',
        created_at: DateTime.now,
        updated_at: DateTime.now,
        id_employeur: nil,
        contrat_en_cours: nil,
        date_debut_contrat: ligne.date_entree,
        date_fin_contrat: ligne.date_sortie,
      )
    }
  end

  def load_carrieres
    return unless valide?

    fhnum = declaration_salaire_manquante.numero

    declaration_chargement_lignes.where(erreur: false).each { |ligne|
      declaration_carrieres.create(
        matric: (ligne.numero_affiliation.nil? or ['0', ''].include?(ligne.numero_affiliation)) ? ligne.nin.delete(' ') : ligne.numero_affiliation.delete(' '),
        fhnum: fhnum,
        prenom: ligne.prenom&.strip,
        nom: ligne.nom&.strip,
        fhrsoc: raison_sociale,
        regime: general? ? '1' : (cadre? ? '2' : nil),
        date_debut_contrat: ligne.date_entree,
        date_fin_contrat: ligne.date_sortie,
        motif_sortie: ligne.motif_sortie,
        date_debut_periode_cotisation: ligne.date_debut_periode_cotisation,
        date_fin_periode_cotisation: ligne.date_fin_periode_cotisation,
        total_sal_css_atmp_1: 0,
        total_sal_css_atmp_2: 0,
        total_sal_css_atmp_3: 0,
        total_sal_css_pf_1: 0,
        total_sal_css_pf_2: 0,
        total_sal_css_pf_3: 0,
        total_sal_ipres_rg_1: 0,
        total_sal_ipres_rg_2: 0,
        total_sal_ipres_rg_3: general? ? ligne.salaire_soumis : 0,
        total_sal_ipres_rcc_1: 0,
        total_sal_ipres_rcc_2: 0,
        total_sal_ipres_rcc_3: cadre? ? ligne.salaire_soumis : 0,
        temps_travail_1: 0,
        temps_travail_2: 0,
        temps_travail_3: 0,
        temps_presence_jour_1: 0,
        temps_presence_jour_2: 0,
        temps_presence_jour_3: 0,
        temps_presence_heures_1: 0,
        temps_presence_heures_2: 0,
        temps_presence_heures_3: 0,
      )
    }
  end

  private

  def set_values
    return unless fichier.attached?

    sheet = Roo::Spreadsheet.open(ActiveStorage::Blob.service.path_for(fichier.key), extension: fichier.filename.extension).sheet(0)
    self.zone = sheet.a9
    self.numero_adherent = sheet.b9
    self.raison_sociale = sheet.c9
    self.date_declaration = sheet.d9
    self.nombre_salaries = sheet.e9
    self.total_salaries = sheet.f9
    self.cotisation_dues = sheet.g9
    self.regime = sheet.b12 == 'RGR' ? 1 : (sheet.b12 == 'RCC' ? 2 : nil)
  end

  def validate_en_tete
    if fichier.attached?
      errors.add(:fichier, 'Regime non valide') unless self.regime == declaration_salaire_manquante.regime
      numero = self.numero_adherent
      numero = "#{numero} "
      numero.delete!(' ').gsub!(/[^0-9]/, '') unless numero.nil?
      errors.add(:fichier, 'Les numéros adhérent ne correspondent pas') unless numero == declaration_salaire_manquante.numero

      sheet = Roo::Spreadsheet.open(ActiveStorage::Blob.service.path_for(fichier.key), extension: fichier.filename.extension).sheet(0)
      exercice = sheet.b16
      errors.add(:fichier, 'Les exercices  ne correspondent pas') unless exercice == declaration_salaire_manquante.exercice
    end
  end

  def validate_statut
    errors.add(:fichier, 'Il y a déjà un chargement en cours de traitement') if declaration_salaire_manquante.en_cours?
    errors.add(:fichier, 'Déjà traité') if declaration_salaire_manquante.chargee?
  end

  def set_statut_declaration_manquante
    if creation? or fichier_valide?
      declaration_salaire_manquante.en_cours!
    elsif valide?
      declaration_salaire_manquante.chargee!
    elsif rejete? or fichier_invalide?
      declaration_salaire_manquante.manquante!
    end
  end
end
