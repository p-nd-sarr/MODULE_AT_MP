class EcheanceCaisseLiquidation < ApplicationRecord
  belongs_to :echeance_caisse_employeur
  belongs_to :echeance_caisse_enfant
  belongs_to :compta_transaction
  belongs_to :echeance_caisse_lot_liquidation

  # @param [User] user
  # @param [ComptaTransaction] compta_transaction
  def liquider(user, compta_transaction)
    ActiveRecord::Base.transaction do
      self.echeance_caisse_enfant.liquide = true
      self.echeance_caisse_enfant.save
      self.liquide = true
      self.compta_transaction = compta_transaction
      self.save
    end
  end
end
