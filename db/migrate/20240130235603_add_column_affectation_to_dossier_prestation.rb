class AddColumnAffectationToDossierPrestation < ActiveRecord::Migration[5.2]
  def change
    add_column :dossier_prestations, :affecte_a_id, :integer
  end
end
