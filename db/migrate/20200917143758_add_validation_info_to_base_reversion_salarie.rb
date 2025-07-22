class AddValidationInfoToBaseReversionSalarie < ActiveRecord::Migration[5.2]
  def change
    add_column :base_reversion_salaries, :etat_ayant_droit_valide, :boolean, default: false
    add_column :base_reversion_salaries, :documents_valide, :boolean, default: false
  
  end
end
