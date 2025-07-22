class MyJob3 < ApplicationJob
  sidekiq_options retry: 2
  queue_as :echeance

  # def perform(numero_ordre)
  def perform
    # OrdrePaiement.find_by(numero: numero_ordre).try(:generate_caisse_paiement)
    r = Enrolement::RegularisationPointage.find(5)

    r.compta_transactions.count

    r.compta_transactions.each { |c|
      c.save
    }
  end
end
