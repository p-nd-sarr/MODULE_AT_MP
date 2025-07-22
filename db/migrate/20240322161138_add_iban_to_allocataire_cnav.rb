class AddIbanToAllocataireCnav < ActiveRecord::Migration[5.2]
  def change
    add_column :allocataire_cnavs, :iban, :integer

    remove_column :dossier_cnavs, :admin_region_id
    remove_column :dossier_cnavs, :admin_agence_id
    remove_column :dossier_cnavs, :agence_creation_id

  end
end
