class AddDateValidationMedecinInFraisEngages < ActiveRecord::Migration[5.2]
  def change
    add_column :at_frais_engages, :date_validation_medecin, :date
  end
end
