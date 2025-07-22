class AtAvi < ApplicationRecord
  AVIS = {
    favorable: 1,
    defavorable: 2,
    complement_information: 3
  }

  enum avis: AVIS
  belongs_to :arret_travail

  validates :description, presence: true, allow_blank: false


  def avis_de
    @user ||= User.find_by(id: fait_par.to_i)
    @user.email
  end

  def peut_supprimer_avis?(current_user)
    if current_user.dprp? || current_user.medecin_conseil? || current_user.directeur_at?
      current_user.id.to_s == self.fait_par
    else
      (current_user.id.to_s == self.fait_par) && (!self.arret_travail.accepte?)
    end
  end

  def can_update_or_delete?(current_user)
    (current_user.id.to_s == self.fait_par) && (!self.arret_travail.accepte?) && can_update_avis?(current_user)
  end

  def can_update_avis?(current_user)
      case current_user.type_profil
      when 'chef_agence'
        arret_travail.en_instruction? and arret_travail.date_soumission_chef_agence.nil? 
      when 'redacteur'
        arret_travail.date_soumission_redacteur.nil? and arret_travail.affecte_redacteur?
      when 'chef_division_at'
        arret_travail.avis_dajc? and arret_travail.date_soumission_avis_chef_service.nil? 
      when 'dajc'
        arret_travail.date_soumission_dajc.nil? 
      when 'directeur_at'
        arret_travail.date_acceptation.nil? 
      when 'dprp'
        arret_travail.date_soumission_avis_dprp.nil?
      when 'medecin_conseil'
        arret_travail.date_soumission_avis_medecin.nil?
      else 
        false
      end
  end

  def valider
    update(est_valide: true)
  end



  def validate_description
    return if description.nil? or description.empty?
    errors.add(:description, "obligatoire")
  end
end
