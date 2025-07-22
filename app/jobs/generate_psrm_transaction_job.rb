class GeneratePsrmTransactionJob < ApplicationJob
  sidekiq_options retry: 5
  # queue_as :comptabilite
  queue_as do
    compta_transaction = self.arguments.first
    if compta_transaction.echeance_paiement_id.nil?
      :comptabilite
    else
      :echeance
    end
  end

  def perform(compta_transaction)
    compta_transaction.generate_psrm_transaction
  end
end
