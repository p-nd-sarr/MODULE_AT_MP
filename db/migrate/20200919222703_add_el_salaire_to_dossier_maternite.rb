class AddElSalaireToDossierMaternite < ActiveRecord::Migration[5.2]
  def change
    add_column :dossier_maternites, :salaire_valid, :boolean, default: false
    DossierMaternite.where(salaire_valid: nil).update_all(salaire_valid: false)
  end
end
