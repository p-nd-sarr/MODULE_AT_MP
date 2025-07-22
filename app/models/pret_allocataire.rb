class PretAllocataire < ApplicationRecord
  ETAT = {
    creation: 1,
    valider: 2,
    rejeter: 3,
    traite: 4
  }.freeze

  enum etat: ETAT

  TYPE_PRET = {
    avance_tabaski: 1,
    # avance_pension: 2,
    # autre: 100,
  }.freeze

  enum type_pret: TYPE_PRET

  belongs_to :ajouter_par, class_name: 'User', foreign_key: :ajouter_par_id, optional: true
  belongs_to :valider_par, class_name: 'User', foreign_key: :validation_id, optional: true

  has_many :pret_allocataire_lignes

  before_create :calcul_date

  def generate_lignes_prets
    if valider? and pret_allocataire_lignes.empty?
      # beneficiaires = Allocataire.actif.senegal.eligibles_pret.where(regime: [1, 2, 3])
      beneficiaires = Allocataire.actif.where(zone: [:senegal, nil]).eligibles_pret.where(regime: [1, 2, 3])
      nb = beneficiaires.count
      i = 0
      beneficiaires.each do |allocataire|
        puts "#{(100.0 * i / nb).ceil(2)} %"
        GenerateLignePretAllocataireJob.perform_later(self, allocataire)
        i += 1
        puts "#{(100.0 * i / nb).ceil(2)} %"
      end

      self.traite!
    end
  end

  private

  def calcul_date
    date = Date.today #.next_month
    self.date_paiement = date #.beginning_of_month
    self.duree_mois = 9
    self.date_debut = self.date_paiement + 2.months
    self.date_fin = self.date_debut + (duree_mois - 1).months
  end
end
