class AddSomeInfosToRegularisationPointageLigne < ActiveRecord::Migration[5.2]
  def change
    add_column :enrolement_regularisation_pointage_lignes, :numero_allocataire, :string, limit: 30, index: true
    add_column :enrolement_regularisation_pointage_lignes, :source, :string, limit: 3, index: true
    add_column :enrolement_regularisation_pointage_lignes, :pointage_id, :integer
    add_column :enrolement_regularisation_pointage_lignes, :source_matching, :string, limit: 50
    add_column :enrolement_regularisation_pointage_lignes, :pres_prenom, :string, limit: 250, index: true
    add_column :enrolement_regularisation_pointage_lignes, :pres_nom, :string, limit: 250, index: true
    add_column :enrolement_regularisation_pointage_lignes, :pres_date_naissance, :string, limit: 15
    add_column :enrolement_regularisation_pointage_lignes, :enr_prenom, :string, limit: 250, index: true
    add_column :enrolement_regularisation_pointage_lignes, :enr_nom, :string, limit: 250, index: true
    add_column :enrolement_regularisation_pointage_lignes, :enr_date_naissance, :string, limit: 15
  end
end
