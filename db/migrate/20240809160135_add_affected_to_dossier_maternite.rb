class AddAffectedToDossierMaternite < ActiveRecord::Migration[5.2]
  def change
    add_column :dossier_maternites, :affecte_a_id, :integer
  end
end
