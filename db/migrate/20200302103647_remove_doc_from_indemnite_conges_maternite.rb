class RemoveDocFromIndemniteCongesMaternite < ActiveRecord::Migration[5.2]
  def change
    remove_column :indemnite_conges_maternites, :debut_grossesse
    remove_column :indemnite_conges_maternites, :document_valid
    remove_column :indemnite_conges_maternites, :salaire_valid
  end
end
