class AddEnTeteComptabiliteToPrestationCss < ActiveRecord::Migration[5.2]
  def change
    add_column :allocation_prenatales, :en_tete_comptabilite, :boolean, default: true
    add_column :allocation_postnatales, :en_tete_comptabilite, :boolean, default: true
    add_column :allocation_familiales, :en_tete_comptabilite, :boolean, default: true
  end
end
