class AddEstJournalierColumnToArretTravails < ActiveRecord::Migration[5.2]
  def change
    add_column :arret_travails, :est_journalier, :boolean,  :default => false
  end
end
