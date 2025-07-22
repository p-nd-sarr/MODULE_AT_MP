class AddDateRepriseReelIndemniteConge < ActiveRecord::Migration[5.2]
  def change
    add_column :indemnite_conges_maternites, :date_reprise_reelle, :datetime
  end
end
