class AddDateValidationMedecinInAtDecompte < ActiveRecord::Migration[5.2]
  def change
    add_column :at_decomptes, :date_validation_medecin, :date
    
  end
end
