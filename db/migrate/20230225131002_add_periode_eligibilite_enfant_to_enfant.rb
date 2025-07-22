class AddPeriodeEligibiliteEnfantToEnfant < ActiveRecord::Migration[5.2]
  def change
    add_column :enfants, :date_debut_eligibilite_af, :date
    add_column :enfants, :date_fin_eligibilite_af, :date
  end
end
