class AtIncapacite < ApplicationRecord

  ETAT = {
    creation: 1,
    liquidation: 2,
    validation: 3,
    validation_compatable: 4,
    validation_medecin:5
  }
  enum etat: ETAT

  NBRE_JOUR_POUR_TECH = 15
  belongs_to :arret_travail
  
  validate :date_debut_valid?

  before_save :check_date

  


  msg = ""
  def est_fait_par
    User.find_by(id: done_by)
  end
  def validation_medecin_obligatoire?
    self.nombre_jour >= NBRE_JOUR_POUR_TECH && !est_valide 
    #self.nombre_jour >= NBRE_JOUR_POUR_TECH 
  end

  def valider
    update(est_valide: true)
  end

  def date_debut_valid?
   
    if date_debut.to_date <= arret_travail.date_accident.to_date
      errors.add(:date_debut, "Date début doit etre superieur  date accident") 
    end
    if date_fin.to_date <= date_debut.to_date
      errors.add(:date_debut, "La date de début incapacité doit etre inferieure à la date de fin incapacité") 
    end
    
      if last_record.date_fin.to_date > date_debut.to_date
        errors.add(:date_debut, "La date de début incapacité doit etre supérieure à la date de fin du précedent arret") 
      end unless last_record.nil?
  end

  def check_date
    if self.nombre_jour.present? && self.nombre_jour > 0
      self.date_fin = self.date_debut + (self.nombre_jour-1).day
    else
      self.nombre_jour = ((self.date_fin - self.date_debut).to_i)
    end
  end

  def last_record
    #abort(arret_travail.at_incapacites.last.date_fin.to_s)
    return arret_travail.at_incapacites.last unless arret_travail.at_incapacites.nil?
  end

  def nb_jour_incapacite
    return ((self.date_fin - self.date_debut).to_i)
  end

  def validate_date
    if date_fin <= date_debut
      msg="ne peut pas être postérieure à la date de debut"
      
      errors.add(:date_fin, msg)
    end
  end
 
  def msg_error
    msg = errors.full_messages.last
   return msg
  end


  
end
