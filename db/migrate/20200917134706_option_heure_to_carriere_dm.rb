class OptionHeureToCarriereDm < ActiveRecord::Migration[5.2]
  def change
    remove_column :carriere_dossier_maternites, :en_heure

    add_column :carriere_dossier_maternites, :presence_en_heure, :boolean, :default => false

  end
end
