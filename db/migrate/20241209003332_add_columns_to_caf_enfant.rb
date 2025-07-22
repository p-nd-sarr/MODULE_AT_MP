class AddColumnsToCafEnfant < ActiveRecord::Migration[5.2]
  def change
    add_column :caf_enfants, :numero_piece, :string
    add_column :caf_enfants, :sexe, :integer
    add_column :caf_enfants, :est_repris, :boolean, default: false
    add_column :caf_enfants, :migrated_document_exp_date, :date
    add_column :caf_enfants, :ajoute_par_id, :integer
    add_column :caf_enfants, :created_at, :timestamp, default: -> { 'CURRENT_TIMESTAMP' }, null: false
    add_column :caf_enfants, :updated_at, :timestamp, default: -> { 'CURRENT_TIMESTAMP' }, null: false
  end
end
