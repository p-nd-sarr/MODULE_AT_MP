class AddDossierIdToIndemniteCongesMaternite < ActiveRecord::Migration[5.2]
  def change
    add_column :indemnite_conges_maternites, :dossier_maternite_id, :integer
  end
end
