class Facture < ApplicationRecord
  TYPE_STATUT= {
      ouverte: 0,
      fermee: 1
  }.freeze

  enum statut: TYPE_STATUT

  #belongs_to :declaration
  #belongs_to  :moratoire
  belongs_to  :user

  def description
    "Période : - #{I18n.l(date_facture , format: :long)} - Montant : #{montant}"
  end
end
