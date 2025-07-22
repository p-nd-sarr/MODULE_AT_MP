class UpdateAllocationMigreePfKeyColumn < ActiveRecord::Migration[5.2]
  def change
    change_column :allocations_postnatales_migrees, :dossier_prestation_id, :string
    change_column :allocations_prenatales_migrees, :dossier_prestation_id, :string
    change_column :allocations_familiales_migrees, :dossier_prestation_id, :string
  end
end
