class AddSalaireToIndemniteCongesMaternite < ActiveRecord::Migration[5.2]
  def change
    add_column :indemnite_conges_maternites, :salaire_valid, :boolean
    add_column :indemnite_conges_maternites, :document_valid, :boolean
  end
end
