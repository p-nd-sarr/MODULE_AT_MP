class AddArretTravailIdToAtConsolidation < ActiveRecord::Migration[5.2]
  def change
    add_reference :at_consolidations, :arret_travail, foreign_key: true
  end
end
