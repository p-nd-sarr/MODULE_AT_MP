class AddDateSoumisionAvisChetServiceAt < ActiveRecord::Migration[5.2]
  def change
    add_column :arret_travails, :date_soumission_avis_chef_service, :datetime
  end
end
