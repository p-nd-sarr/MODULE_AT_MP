class MyJob4 < ApplicationJob
  sidekiq_options retry: 2
  queue_as :echeance

  def perform(id)
    DecesSalarie.find(id).save
  end
end
