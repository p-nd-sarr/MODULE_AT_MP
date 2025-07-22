class AddDateClotureDossier < ActiveRecord::Migration[5.2]
  def change
    add_column :arret_travails, :date_cloture_dossier, :datetime
    add_column :arret_travails, :date_reouverture_dossier, :datetime
  end
end
