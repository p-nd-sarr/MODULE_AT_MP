class Psrm::EnteteDeclaration < Psrm::DbBase
  self.table_name = 'XX_ENTETE_DECLARATION_NAP'
  has_many :declaration_lignes, foreign_key: :ID_DECLARATION, primary_key: 'ID_DECLARATION'
end