class MyJob < ApplicationJob
  sidekiq_options retry: 5
  queue_as :my_queue

  def perform(echeance_id, historique)
    historique.load(echeance_id)
  end
end
