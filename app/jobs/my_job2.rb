class MyJob2 < ApplicationJob
  sidekiq_options retry: 5
  queue_as :my_queue

  def perform(numero, montant, mew_montant_rappel)
    # allocataire.recalculer_allocation(Date.new(2022, 1, 1))
    # allocataire.new_montant_net_m1 = allocataire.montant_net
    # allocataire.save
    # allocataire.recalculer_allocation(Date.new(2022, 2, 1))
    # allocataire.new_montant_net_m2 = allocataire.montant_net
    # allocataire.save
    # allocataire.recalculer_allocation(Date.new(2022, 3, 1))
    # allocataire.new_montant_net_m3 = allocataire.montant_net
    # allocataire.save
    puts('OK')
  end
end
