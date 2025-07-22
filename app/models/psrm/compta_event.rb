class Psrm::ComptaEvent < Psrm::DbBase
  self.table_name = 'cisadm.XXIPRES_CSS_OP_DET'

  attribute :legal_entity_id, :integer
  attribute :entity_id, :integer
  attribute :event_id, :integer
  attribute :created_by, :integer
  attribute :montant_ligne, :integer
  attribute :created_by, :integer

=begin
  LEGAL_ENTITY_ID
  ENTITY_ID
  EVENT_ID
  CODE_TYPE_LIGNE_OPERATION
  DESC_LIGNE_PAIEMENT
  MONTANT_LIGNE
  ATTRIBUTE1
  ATTRIBUTE2
  ATTRIBUTE3
  ATTRIBUTE4
  ATTRIBUTE5
  ATTRIBUTE6
  ATTRIBUTE7
  ATTRIBUTE8
  ATTRIBUTE9
  ATTRIBUTE10
  ATTRIBUTE11
  ATTRIBUTE12
  ATTRIBUTE13
  ATTRIBUTE14
  ATTRIBUTE15
  CREATION_DATE
  CREATED_BY
  LAST_UPDATE_DATE
  LAST_UPDATED_BY
  LAST_UPDATE_LOGIN
=end
end