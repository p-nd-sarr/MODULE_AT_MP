class DeclarationCarriere < ApplicationRecord
  belongs_to :declaration_chargement
  belongs_to :employeur, class_name: 'Psrm::Employeur', foreign_key: :fhnum, primary_key: :fhnum, optional: true
  belongs_to :participant, :class_name => 'Psrm::Participant', foreign_key: :matric, primary_key: :matric, optional: true

  after_create :load_to_psrm

  def participant
    Psrm::Participant.find_by(matric: matric)
  end

  def date_debut
    date_debut_periode_cotisation
  end

  def date_fin
    date_fin_periode_cotisation
  end

  def nb_jours_travail
    (date_fin - date_debut).to_i + 1
  end

  def exercice
    date_debut.year
  end

  def self.lineaire?(matricule)
    carrieres = Psrm::Carriere.where(matric: matricule)
    return true if carrieres.empty?
    exercices = carrieres.map(&:exercice).uniq
    annee_min = exercices.min
    annee_max = exercices.max
    ((annee_min..annee_max).to_a - exercices).empty?
  end

  def self.lineaire_employeur?(employeur_id)
    carrieres = Psrm::Carriere.where(fhnum: employeur_id)
    return true if carrieres.empty?
    exercices = carrieres.map(&:exercice).uniq
    annee_min = exercices.min
    annee_max = exercices.max
    ((annee_min..annee_max).to_a - exercices).empty?
  end

  def salaire_rg
    (total_sal_ipres_rg_1 || 0) + (total_sal_ipres_rg_2 || 0) + (total_sal_ipres_rg_3 || 0)
  end

  def salaire_rcc
    (total_sal_ipres_rcc_1 || 0) + (total_sal_ipres_rcc_2 || 0) + (total_sal_ipres_rcc_3 || 0)
  end

  def calcul_points_rg
    points_rg
    # return 0 if salaire_rg.zero? or bareme_rg.nil?
    # (1.0 * [salaire_rg, bareme_rg.plafond_salaire].min * bareme_rg.coefficient).round
  end

  def calcul_points_rcc
    points_rc
    # return 0 if salaire_rcc.zero? or bareme_rcc.nil?
    # (1.0 * [salaire_rcc, bareme_rcc.plafond_salaire].min * bareme_rcc.coefficient).round
  end

  def calcul_points
    calcul_points_rg + calcul_points_rcc
  end

  def load_to_psrm
    return if Psrm::Carriere.exists?(edi_id: self.id)

    p =  Psrm::Participant.find_by("matric = ? or ipres_ancien_matric = ?", self.matric, self.matric)

    matricule = p.nil? ? self.matric : p.matric

    Psrm::Carriere.create(
      matric: matricule,
      fhnum: self.fhnum,
      prenom: self.prenom,
      nom: self.nom,
      fhrsoc: self.fhrsoc,
      regime: self.regime,
      date_debut_contrat: self.date_debut_contrat,
      date_fin_contrat: self.date_fin_contrat,
      motif_sortie: self.motif_sortie,
      date_debut_periode_cotisation: self.date_debut_periode_cotisation,
      date_fin_periode_cotisation: self.date_fin_periode_cotisation,
      total_sal_css_atmp_1: self.total_sal_css_atmp_1,
      total_sal_css_atmp_2: self.total_sal_css_atmp_2,
      total_sal_css_atmp_3: self.total_sal_css_atmp_3,
      total_sal_css_pf_1: self.total_sal_css_pf_1,
      total_sal_css_pf_2: self.total_sal_css_pf_2,
      total_sal_css_pf_3: self.total_sal_css_pf_3,
      total_sal_ipres_rg_1: self.total_sal_ipres_rg_1,
      total_sal_ipres_rg_2: self.total_sal_ipres_rg_2,
      total_sal_ipres_rg_3: self.total_sal_ipres_rg_3,
      total_sal_ipres_rcc_1: self.total_sal_ipres_rcc_1,
      total_sal_ipres_rcc_2: self.total_sal_ipres_rcc_2,
      total_sal_ipres_rcc_3: self.total_sal_ipres_rcc_3,
      temps_travail_1: self.temps_travail_1,
      temps_travail_2: self.temps_travail_2,
      temps_travail_3: self.temps_travail_3,
      temps_presence_jour_1: self.temps_presence_jour_1,
      temps_presence_jour_2: self.temps_presence_jour_2,
      temps_presence_jour_3: self.temps_presence_jour_3,
      temps_presence_heures_1: self.temps_presence_heures_1,
      temps_presence_heures_2: self.temps_presence_heures_2,
      temps_presence_heures_3: self.temps_presence_heures_3,
      points_rc: self.points_rc,
      points_rg: self.points_rg,
      edi_id: self.id,
    )
  end
end
