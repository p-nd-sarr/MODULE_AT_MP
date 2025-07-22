class Admin::CafBareme < ApplicationRecord
  PERIODE = {
      mensuelle: 1,
      annuelle: 2
  }.freeze

  enum periode: PERIODE


  validates :periode, :montant_indemnites, :date_debut_validite,
            :date_fin_validite,
            presence: true


  scope :en_cours, -> { where("date_debut_validite <= ? AND date_fin_validite >= ?", Date.today, Date.today) }
  scope :annee_precedente, -> { where("date_debut_validite <= ? AND date_fin_validite >= ?", Date.today.last_year, Date.today.last_year) }


end
