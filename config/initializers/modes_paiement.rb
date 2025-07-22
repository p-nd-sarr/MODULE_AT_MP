MODE_PAIEMENT = {
  mandant_postal: 1,
  virement: 2,
  wari: 3,
  caisse_ipres: 4,
  post_finance: 5,
  mise_a_disposition_bancaire: 6,
  paiement_departemental: 7,
  carte_prepaye: 8,
  paiement_a_domicile: 9,
  cheque: 10,
  caisse_css: 11,
  orange_money: 12,
  wave: 13,
  paiement_hors_convention: 14,
  autres: 100
}.freeze

MODE_PAIEMENT_CAISSE_IPRES = {
  mandant_postal: 1,
  virement: 2,
  # caisse_ipres: 4,
  # post_finance: 5,
  mise_a_disposition_bancaire: 6,
  carte_prepaye: 8,
  paiement_a_domicile: 9,
  orange_money: 12,
  wave: 13,
  paiement_hors_convention: 14,
  autres: 100
}.freeze

MODE_PAIEMENT_CAISSE_CSS = {
  virement: 2,
  carte_prepaye: 8,
  cheque: 10,
  caisse_css: 11,
  autres: 100
}.freeze

REGIME = {
  general: 1,
  cadre: 2,
  employe_de_maison: 3
}.freeze
