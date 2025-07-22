class AddDateEnregistrementPrestation < ActiveRecord::Migration[5.2]

  def self.up
    add_column :dossier_prestations, :date_enregistrement, :date
  end

  def self.down
    remove_column :dossier_prestations, :date_enregistrement
  end

end
