class AddGenerationPaiementEnCoursToDossierMaternite < ActiveRecord::Migration[5.2]
  def change
    add_column :dossier_maternites, :generation_paiement_encours, :boolean, default: false
  end
end
