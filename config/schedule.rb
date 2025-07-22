# Use this file to easily define all of your cron jobs.
#
# It's helpful, but not entirely necessary to understand cron before proceeding.
# http://en.wikipedia.org/wiki/Cron

# Example:
#
# set :output, "/path/to/my/cron_log.log"
#
# every 2.hours do
#   command "/usr/bin/some_great_command"
#   runner "MyModel.some_method"
#   rake "some:great:rake:task"
# end
#
# every 4.days do
#   runner "AnotherModel.prune_old_records"
# end
#
# cron
# mm hh jj MMM JJJ

env :PATH, ENV['PATH']
env :GEM_HOME, ENV['GEM_HOME']

# Learn more: http://github.com/javan/whenever
set :chronic_options, hours24: true

every '1 0 * * *' do
  rake 'batch:send_messages'
end

every 1.year, at: 'March 31th 11:59am' do
  rake 'prestation_exterieure_caf:suspendre_dossier'
end

every '0 19 * * *' do # OK, améliorer le script
  rake 'prestations:generate_lignes_prets'
end

every '1 0 20 * *' do # OK
  rake 'prestations:generate_echeances', output: {error: "#{path}/log/echeance_error.log", standard: "#{path}/log/echeance_std.log"}
end

every '1 0 21-31 * *' do # OK
  rake 'prestations:generate_comptabilite_echeances', output: {error: "#{path}/log/echeance_compta_error.log", standard: "#{path}/log/echeance_compta_std.log"}
end

# every '0 17 * * *' do # OK
#   rake 'prestations:generate_regularisation_pointage', output: {error: "#{path}/log/regularisation_pointage_error.log", standard: "#{path}/log/regularisation_pointage_std.log"}
# end
#
# every '0 19,20,21,23,0 * * *' do # OK
#   rake 'prestations:generate_comptabilite_regularisation_pointage', output: {error: "#{path}/log/regularisation_pointage_error.log", standard: "#{path}/log/regularisation_pointage_std.log"}
# end

every '0 23 * * *' do
  rake 'dossier_prestation:cloturer_dossier'
end

every '0 19 * * *' do
  rake 'allocation_familiale_echue:suspendre_allocation'
end

every '0 0 * * *' do
  rake 'comptabilite:set_numero_ordre'
end

every 1.day, at: '12:00 am' do
  rake 'allocation_familiale_doc_valid:set_allocation_familiale_invalid'
end

# every '0 21 13 3,6,9,12 *' do
#   rake 'send_echeance_time_of_presence:send_time_of_presence'
# end

# echeance CSS

every '1 0 10 * *' do # OK
  rake 'echeance_css:set_periode_eligibilite_enfant'
end

# every '1 0 31 3,6,9,12 *' do # OK
#   rake 'echeance_css:run'
# end
