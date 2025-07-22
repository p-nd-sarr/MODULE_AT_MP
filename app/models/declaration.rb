class Declaration < ApplicationRecord
  TYPE_STATUT = {
      declaration: 'DNS',
      regularisation: 'Regularisation',
      majoration: 'Majoration',
      penalites: 'Pénalités'
  }.freeze

  STATUT = {
      creation: 1,
      soumis: 2,
      manquante: 3,
      valide: 4
  }.freeze

  enum statut: STATUT

  #Déclaration, Regularisation, Majoration, Pénalités
  belongs_to :user
  has_many :factures

  def synthese_valide!(est_valide = true)
    update(synthese_valide: est_valide)
  end

  def mouvement_effectif_valide!(est_valide = true)
    update(mouvement_effectif_valide: est_valide)
  end

  def recap_salarie_valide!(est_valide = true)
    update(recap_salarie_valide: est_valide)
  end

  def soumettre_demande!
    update(etat: :soumis, statut: :soumis, date_soumission: DateTime.now)
  end

  def pret_pour_soumission?
    mouvement_effectif_valide and synthese_valide and recap_salarie_valide
  end
end