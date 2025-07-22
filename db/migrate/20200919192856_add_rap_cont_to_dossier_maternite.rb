class AddRapContToDossierMaternite < ActiveRecord::Migration[5.2]
  def change
    add_column :dossier_maternites, :rapport_controle, :text
    add_column :dossier_maternites, :date_rapport, :datetime
  end
end
