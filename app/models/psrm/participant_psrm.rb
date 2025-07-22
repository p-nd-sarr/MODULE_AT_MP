class Psrm::ParticipantPsrm < Psrm::DbBase
  self.table_name = 'CISADM.CM_SALARIER_VIEW'

=begin
  Nom                 NULL ?   Type
  ------------------- -------- -------------
  MATRIC              NOT NULL CHAR(10)
  IPRES_ANCIEN_MATRIC          VARCHAR2(16)
  CSS_ANCIEN_MATRIC            VARCHAR2(16)
  PRENOM                       VARCHAR2(50)
  NOM                          VARCHAR2(50)
  TYPE_PIECE                   VARCHAR2(15)
  NUMERO_PIECE                 VARCHAR2(15)
  PROFESSION                   VARCHAR2(600)
  EMPLOI                       VARCHAR2(35)
  REGIME                       VARCHAR2(3)
  ADDR                         VARCHAR2(254)
  PHONE                        VARCHAR2(24)
  DATE_NAISSANCE               DATE
  GENRE                        VARCHAR2(254)
=end

  has_many :carrieres, foreign_key: :matric, primary_key: :matric
  #belongs_to :employeur, foreign_key: :fhnum, primary_key: :fhnum

  def full_name
    "#{prenom} #{nom}"
  end

  def nombre_annee_cotisation
    carrieres.map(&:exercice).uniq.count
  end

  def libelle_regime
    regime
  end

  def homme?
    genre == 'HOMME' # 1
  end

  def femme?
    genre == 'FEMME' # 2
  end

  def nb_jours_travail
    carrieres.map(&:nb_jours_travail).sum
  end

  def nb_mois_travail
    (nb_jours_travail / 30.437).ceil
  end

  def nb_trimestre_travail
    ((nb_jours_travail / 30.437) / 3).ceil
  end

  def date_premiere_embauche
    carrieres.order('date_debut_periode_cotisation DESC').last.try(:date_debut_contrat)
  end

  def date_fin_derniere_embauche
    carrieres.order('date_debut_periode_cotisation DESC').first.try(:date_fin_contrat)
  end

  def dernier_salaire
    c = carrieres.order('date_debut_periode_cotisation DESC').first
    c.nil? ? 0 : c.salaire_rcc + c.salaire_rg
  end

  def derniere_carriere
    carrieres.order('date_debut_periode_cotisation DESC').first
  end

  # en jours
  def duree_derniere_carriere
    c = carrieres.order('date_debut_periode_cotisation DESC').first
    c.nil? ? 0 : (c.date_debut - c.date_fin).to_i + 1
  end

  def duree_derniere_carriere_en_mois
    (duree_derniere_carriere / 30.437).ceil
  end

  def dernier_salaire_mensuel
    c = carrieres.order('date_debut_periode_cotisation DESC').first
    c.nil? ? 0 : (dernier_salaire / 30.437).ceil
  end
end