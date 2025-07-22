class AddConventionToDossierCnav < ActiveRecord::Migration[5.2]
  def change
    add_column :dossier_cnavs, :type_convention, :integer
    DossierCnav.where(type_convention: nil).update_all(type_convention: 1)
  end
end
