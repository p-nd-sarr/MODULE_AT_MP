class CarriereDossierPrestation < ApplicationRecord

  include ::SetDate

  TRIMESTRE = {
    trimestre1: 1,
    trimestre2: 2,
    trimestre3: 3,
    trimestre4: 4
  }.freeze

  enum allocation_etat: AllocationFamiliale.etats
  enum trimestre: TRIMESTRE

  belongs_to :dossier_prestation, foreign_key: :dossier_prestation_id
  belongs_to :psrm_employeur, :class_name => 'Psrm::Employeur', foreign_key: :num_employeur, primary_key: :fhnum
  belongs_to :bordereau_collectif, :class_name => 'BordereauCollectif', foreign_key: :bordereau_collectif_id, optional: true
  belongs_to :echeance_caisse, :class_name => 'EcheanceCaisse', foreign_key: :echeance_caisse_id, optional: true
  belongs_to :echeance_caisse_lot_liquidation, :class_name => 'EcheanceCaisseLotLiquidation', foreign_key: :echeance_caisse_lot_liquidation_id, optional: true

  has_one_attached :document

  before_save :remove_motif_if_not_necessary
  after_save :create_allocation_f
  after_destroy :delete_associated_allocation_f
  before_update :delete_associated_allocation_f

  validates :document, content_type: { in: 'application/pdf', message: "n'est pas un PDF" }, on: :create
  validates :trimestre, :annee, :premier_mois, :deuxiem_mois, :troisiem_mois, :num_employeur, :raison_sociale, presence: true, on: :create
  validates :premier_mois, :deuxiem_mois, :troisiem_mois, presence: true, on: :update
  validate :valider_temps_de_presence, on: :create
  #validate :valider_duree_temps_de_presence
  validate :valider_trimestre
  validate :valider_posterite_tp
  validate :tp_saved_in_echeance
  validate :salary_age_on_trimester
  validate :number_day_of_last_month

  def number_day_of_last_month
    trimestre_value = 0
    if trimestre1?
      trimestre_value = 1
    elsif trimestre2?
      trimestre_value = 2
    elsif trimestre3?
      trimestre_value = 3
    elsif trimestre4?
      trimestre_value = 4
    end
    if premier_mois.nil?
      errors.add(:premier_mois, ': nombre de jours doit être renseigné')
      return
    end
    if deuxiem_mois.nil?
      errors.add(:deuxiem_mois, ': nombre de jours doit être renseigné')
      return
    end
    if troisiem_mois.nil?
      errors.add(:troisiem_mois, ': nombre de jours doit être renseigné')
      return
    end
    unless premier_mois.between?(0, Date.new(self.annee, (trimestre_value * 3) - 2, 1).end_of_month.day)
      errors.add(:premier_mois, ': nombre de jours incorrecte')
      return
    end
    unless deuxiem_mois.between?(0, Date.new(self.annee, (trimestre_value * 3) - 1, 1).end_of_month.day)
      errors.add(:deuxiem_mois, ': nombre de jours incorrecte')
      return
    end
    unless troisiem_mois.between?(0, Date.new(self.annee, (trimestre_value * 3), 1).end_of_month.day)
      errors.add(:troisiem_mois, ': nombre de jours incorrecte')
      return
    end

    if troisiem_mois?
      date_ref = Date.new(self.annee, trimestre_value * 3, troisiem_mois)
    end
    if infos_jour? and troisiem_mois and troisiem_mois != 0 and (date_ref >= Date.today)
      errors.add(:troisiem_mois, ': Le salarié ne peut pas avoir travaillé autant de jours.')
    end
  end

  def salary_age_on_trimester
    trimestre_value = 0
    if trimestre1?
      trimestre_value = 1
    elsif trimestre2?
      trimestre_value = 2
    elsif trimestre3?
      trimestre_value = 3
    elsif trimestre4?
      trimestre_value = 4
    end
    end_date = Date.new(self.annee, trimestre_value * 3, 1).beginning_of_quarter
    if dossier_prestation.date_naissance + 60.years < end_date
      errors.add(:base, "Le salarié est déjà à la retraite")
    end
  end

  def tp_saved_in_echeance
    echeance = EcheanceCaisse.find_by(trimestre: CarriereDossierPrestation.trimestres[self.trimestre], annee: self.annee)
    return if echeance.nil?
    if dossier_prestation.echeance_caisse_dossiers.exists?(echeance_caisse_id: echeance.id) and echeance_caisse_id.nil?
      errors.add(:base, "Salarié déjà pris en charge dans l'écheance de ce trimestre !")
    end
  end

  def valider_posterite_tp
    if self.dossier_prestation.date_ouverture.nil?
      errors.add(:base, "Veuillez renseigner la date d'ouverture des droits")
      return
    end

    trimestre_value = 0
    if trimestre1?
      trimestre_value = 1
    elsif trimestre2?
      trimestre_value = 2
    elsif trimestre3?
      trimestre_value = 3
    elsif trimestre4?
      trimestre_value = 4
    end

    date_ref = Date.new(self.annee, trimestre_value * 3, 1).end_of_month
    if self.dossier_prestation.date_ouverture > date_ref
      errors.add(:base, "Ce trimestre est invalide : postérieur à la date d'ouverture des droits")
    end
  end

  def valider_temps_de_presence
    carrieres = CarriereDossierPrestation.where(dossier_prestation_id: dossier_prestation_id)
    return if carrieres.count.nil?

    carrieres.each { |carriere|
      if carriere.trimestre.eql? trimestre and carriere.annee.eql? annee
        puts(:base, 'Ce trimestre est déja saisit pour cette année')
        errors.add(:base, 'Ce trimestre est déja saisit pour cette année')
      end
    }
  end

  def valider_duree_temps_de_presence
    unless est_justifier?
      if infos_jour? and premier_mois? and (premier_mois < 22 || premier_mois > 30)
        errors.add(:premier_mois, 'Le nombre de jours doit être compris entre (22) et (30)')
      elsif infos_jour? and deuxiem_mois and (deuxiem_mois < 22 || deuxiem_mois > 30)
        errors.add(:deuxiem_mois, 'Le nombre de jours doit être compris entre (22) et (30)')
      elsif infos_jour? and troisiem_mois and (troisiem_mois < 22 || troisiem_mois > 30)
        errors.add(:troisiem_mois, 'Le nombre de jours doit être compris entre (22) et (30)')
      elsif !infos_jour? and premier_mois? and (premier_mois < 120)
        errors.add(:premier_mois, 'Le nombre d\'heure doit être spérieur ou égal à 120H')
      elsif !infos_jour? and deuxiem_mois? and (deuxiem_mois < 120)
        errors.add(:deuxiem_mois, 'Le nombre d\'heure doit être spérieur ou égal à 120H')
      elsif !infos_jour? and troisiem_mois? and (troisiem_mois < 120)
        errors.add(:troisiem_mois, 'Le nombre d\'heure doit être spérieur ou égal à 120H')
      end
    end
  end

  def valider_trimestre
    trimestre_value = 0
    if trimestre1?
      trimestre_value = 1
    elsif trimestre2?
      trimestre_value = 2
    elsif trimestre3?
      trimestre_value = 3
    elsif trimestre4?
      trimestre_value = 4
    end
    end_date = Date.new(annee, trimestre_value * 3, 1) + 14.days

    if end_date > Date.today
      errors.add(:trimestre, "Le trimestre saisit n'est pas encore à terme")
    end

=begin
    if annee? and annee >= Date.today.year and trimestre_value >= (Date.today.month / 3.0).ceil
      errors.add(:trimestre, "Le trimestre saisit n'est pas encore à terme")
    end
=end
  end

  def create_allocation_f
    return if not echeance_caisse.nil?

    participant = self.dossier_prestation.participant
    date = Date.new(self.annee, self.read_attribute_before_type_cast(:trimestre) * 3, 19)

    period = set_period_for_allocation_f(self.read_attribute_before_type_cast(:trimestre), self.annee)

    enfants = participant.enfants
                         .eligible_for_alloc_familiale(period, participant.matric)
                         .select { |enfant| enfant.has_document_valid?(self.annee, self.read_attribute_before_type_cast(:trimestre)) }
                         .sort_by(&:date_naissance)
                         .take(6)

    enfants.each do |enfant|
      migrated_allocation = self.dossier_prestation.allocations_familiales_migrees.find_by(annee: annee, trimestre: self.read_attribute_before_type_cast(:trimestre), enfant_id: enfant.old_id)
      next unless migrated_allocation.nil?
      allocation = AllocationFamiliale.new
      allocation.enfant_id = enfant.id
      allocation.dossier_prestation_id = self.dossier_prestation_id
      allocation.trimestre = self.read_attribute_before_type_cast(:trimestre)
      allocation.annee = self.annee
      allocation.date_ouverture_droit = Date.today
      allocation.date_reception = self.date_document
      allocation.ajoute_par = User.current
      allocation.etat = :creation
      #allocation.date_debut_validite = date.at_beginning_of_month.next_month
      allocation.date_debut_validite = date
      allocation.date_fin_validite = date.end_of_month + 1.year
      allocation.admin_agence = User.current.agence
      # allocation.is_from_ech_paid = true unless self.echeance_caisse_id.nil?
      # allocation.echeance_caisse_id = self.echeance_caisse_id unless self.echeance_caisse_id.nil?
      # allocation.echeance_caisse_lot_liquidation_id = self.echeance_caisse_lot_liquidation_id unless self.echeance_caisse_lot_liquidation_id.nil?
      puts 'error', allocation.errors.full_messages unless allocation.save
    end
  end

  def is_expired_tdp
    (Date.new(self.annee, self.read_attribute_before_type_cast(:trimestre) * 3, 1).end_of_month + 1.year) >= Date.today
  end

  def delete_associated_allocation_f
    AllocationFamiliale.where(trimestre: trimestre, annee: annee, dossier_prestation_id: dossier_prestation_id, paiement: false).destroy_all
  end

  def find_bordereau
    employeur = Psrm::Employeur.find_by_fhnum(self.num_employeur)
    return nil if employeur.nil?
    searched_bordereau = BordereauCollectif.joins(:bordereau_salaries_assocs).where(bordereau_collectifs: { annee: self.annee, trimestre: self.read_attribute_before_type_cast(:trimestre), employeur_id: employeur.id, bordereau_type: BordereauCollectif.bordereau_types[:normal] }).where(bordereau_salaries_assocs: { participant_id: self.dossier_prestation.num_affiliation }).first
    searched_bordereau
  end

  def check_time_of_presence(item)
    if item == 1
      if self.infos_jour?
        if self.premier_mois < 18 and est_justifier?
          return true
        elsif self.premier_mois < 18 and !est_justifier?
          return false
        end
        return nil
      else
        if self.premier_mois < 120 and est_justifier?
          return true
        elsif self.premier_mois < 120 and !est_justifier?
          return false
        end
        return nil
      end
    end

    if item == 2
      if self.infos_jour?
        if self.deuxiem_mois < 18 and est_justifier_mois2?
          return true
        elsif self.deuxiem_mois < 18 and !est_justifier_mois2?
          return false
        end
        return nil
      else
        if self.deuxiem_mois < 120 and est_justifier_mois2?
          return true
        elsif self.deuxiem_mois < 120 and !est_justifier_mois2?
          return false
        end
        return nil
      end
    end

    if item == 3
      if self.infos_jour?
        if self.troisiem_mois < 18 and est_justifier_mois3?
          return true
        elsif self.troisiem_mois < 18 and !est_justifier_mois3?
          return false
        end
        return nil
      else
        if self.troisiem_mois < 120 and est_justifier_mois3?
          return true
        elsif self.troisiem_mois < 120 and !est_justifier_mois3?
          return false
        end
        return nil
      end
    end
  end

  def remove_motif_if_not_necessary
    unless est_justifier?
      self.motif_mois1 = nil
    end

    unless est_justifier_mois2?
      self.motif_mois2 = nil
    end

    unless est_justifier_mois3?
      self.motif_mois3 = nil
    end

  end

end
