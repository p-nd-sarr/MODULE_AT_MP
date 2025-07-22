class AtDossierReversionRente < ApplicationRecord
  include Documentable

    TYPE_DOCUMENT_OBLIGATOIRE_VEUVE = {
  
  }.freeze

  TYPE_DOCUMENT_VEUVE = TYPE_DOCUMENT_OBLIGATOIRE_VEUVE.merge(
      {
          copie_cni: 21,
          acte_etat_civil_jug_supp_veuve: 22,
          jug_here_cert_non_opp_non_app: 23,
          certificat_tutelle: 25,
      }
  ).freeze

  TYPE_DOCUMENT_OBLIGATOIRE_ORPHELIN = {

  }.freeze

  TYPE_DOCUMENT_ORPHELIN = TYPE_DOCUMENT_OBLIGATOIRE_ORPHELIN.merge(
      {         
          certificat_tutelle: 25,
          copie_cni: 21,
          extrait_naissance: 2,
          certificat_scolarite: 36,
          certificat_medical: 19,
      }
  ).freeze

  ETAT = {
      creation: 0,
      soumis: 1,
      valide: 2,
      rejete: 3
  }.freeze

  enum etat: ETAT

  enum mode_paiement: MODE_PAIEMENT

  TYPE_AYANT_DROIT = {
      veuve: 1,
      orphelin: 2,
      pere: 3,
      mere: 4
  }.freeze

  enum type_ayant_droit: TYPE_AYANT_DROIT

  has_one :enfant, foreign_key: :numero_affiliation, primary_key: :numero_affiliation
  has_one :conjoint, foreign_key: :numero_affiliation, primary_key: :numero_affiliation
  has_one :ascendants_salarie, foreign_key: :numero_affiliation, primary_key: :numero_affiliation
  belongs_to :at_rente_famille
  has_one_attached :document


  #belongs_to :traite_par, class_name: 'User', foreign_key: :traite_par_id, optional: true
  #belongs_to :ajoute_par, class_name: 'User', foreign_key: :ajoute_par_id
  #belongs_to :instruit_par, class_name: 'User', foreign_key: :instruit_par_id, optional: true
  #belongs_to :valider_par, class_name: 'User', foreign_key: :valider_par_id, optional: true
  #belongs_to :affecter_allocataire, class_name: 'User', foreign_key: :affecter_a, optional: true

  validates :conjoint_id, presence: true, uniqueness: {message: 'Une demande de reversion existe déjà pour cette personne'}, if: :veuve?
  validates :enfant_id, presence: true, uniqueness: {message: 'Une demande de reversion existe déjà pour cette personne'}, if: :orphelin?
  before_create :set_numero_dossier
  # after_save :create_allocataire!
  #before_save :set_infos_beneficiaires!

  def taux_retenu
    return at_rente_famille.taux_total_conjoints/at_rente_famille.nombre_conjoints if veuve?
    return at_rente_famille.taux_total_enfants/at_rente_famille.nombre_enfants  if orphelin?
  end

  def montant_annuel_rente
    puts "R_ATF",at_rente_famille.montant_rente_annuel_enfant
    return at_rente_famille.montant_rente_annuel_enfant if orphelin?
    return at_rente_famille.montant_rente_annuel_conjoit if veuve?
    return at_rente_famille.montant_rente_annuel_ascendant if mere? ou pere?
  end
  

  def capital
    return (at_rente_famille.montant_rente_annuel_enfant*prix_franc_rente_enfant).round if orphelin?
    return (at_rente_famille.montant_rente_annuel_conjoit*prix_franc_rente_conjoint).round if veuve?
    return (at_rente_famille.montant_rente_annuel_ascendant*prix_franc_rente_conjoint).round  if mere? ou pere?
  end

  def montant_rente_trimestre
   return montant_annuel_rente/4
  end

  def age_conversion_enfant
    return (at_rente_famille.date_deces.year - enfant.date_naissance.year) 
  end

  def age_conversion_conjoint
    return (at_rente_famille.date_deces.year - conjoint.date_naissance.year) 
  end

  def age_conversion_ascendant
    return (at_rente_famille.date_deces.year - ascendants_salarie.date_naissance.year) 
  end

  def prix_franc_rente_enfant
    puts "AGE Conversion",age_conversion_enfant
    if age_conversion_enfant <= 80
      return Admin::Rente.find_by(age: age_conversion_enfant).prix 
    else
      return Admin::Rente.find_by(age: 80).prix 
    end
  end

  def prix_franc_rente_conjoint
    puts "AGE Conversion",age_conversion_conjoint
    if age_conversion_conjoint <= 80
      return Admin::Rente.find_by(age: age_conversion_conjoint).prix 
    else
      return Admin::Rente.find_by(age: 80).prix 
    end
  end

  def prix_franc_rente_ascendant
    puts "AGE Conversion",age_conversion_ascendant
    if age_conversion_ascendant <= 80
      return Admin::Rente.find_by(age: age_conversion_ascendant).prix 
    else
      return Admin::Rente.find_by(age: 80).prix 
    end
  end

  def montant_versement 
    return montant_rente_trimestre
  end

  def montant_arrerage
     return (montant_rente_trimestre * at_rente_famille.nombre_jours_echus/90).round
   end

  def pret_pour_valider_dossier?
    etat_ayant_droit_valide and documents_valide
  end

  def pret_pour_soumission?
    etat_ayant_droit_valide and documents_valide
  end
   
  def montant_rente
    return rente_enfant if orphelin?
    return rente_conjoint if veuve?
    return rente_mere if pere?
    return rente_pere if mere?
  end

  
  private
  def validate_conjoint_or_enfant
    errors.add(:conjoint_id, "Dossier pour cet ayant droit existe déjà") if AtDossierReversionRente.where(conjoint_id: conjoint_id).exists?
    errors.add(:enfant_id, "Dossier pour cet ayant droit existe déjà") if AtDossierReversionRente.where(enfant_id: enfant_id).exists?
  end

  def set_numero_dossier
    annee = Date.today.year
    prefixe = veuve? ? 'V':
    prefixe = orphelin? ? 'O':
    prefixe = pere? ? 'P': 'M'    
   
    dernier_dossier_ajoute = AtDossierReversionRente.where(
      numero_affiliation: numero_affiliation,
      type_ayant_droit: type_ayant_droit
    ).order('created_at DESC').first

    if dernier_dossier_ajoute.nil?
      self.numero_dossier = "#{prefixe}/#{numero_affiliation}/#{annee}/01"
    else
      a = dernier_dossier_ajoute.numero_dossier.split('/')
      a[2] = annee
      self.numero_dossier = a.join('/').next
    end
  end

  def set_infos_beneficiaires!
    if veuve?
      self.enfant = nil
    else
      self.conjoint = nil
    end
    self.prenom = (conjoint || enfant).prenom
    self.nom = (conjoint || enfant).nom
    self.date_naissance = (conjoint || enfant).date_naissance
  end

end