class Psrm::Reglement < Psrm::DbBase
  self.table_name = 'XX_REGLEMENT_NAP'

  TYPE_REGLEMENT= {
      versement: 0,
      avance: 1,
      solde: 2
  }.freeze

  enum CODE_TYPE_REGLEMENT: TYPE_REGLEMENT
end