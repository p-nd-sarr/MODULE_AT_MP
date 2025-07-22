namespace :batch do
  desc "TODO"
  task send_messages: :environment do
    puts "====> size #{Allocataire.count}"
  end
end