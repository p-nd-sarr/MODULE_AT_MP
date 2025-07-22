class UpdateSchemaToEnfant < ActiveRecord::Migration[5.2]
  def change
    # remove_column :enfants, :conjoint_id
    add_column :enfants, :nom_salarie, :string
    add_column :enfants, :prenom_salarie, :string
    add_column :enfants, :full_name_conjoint, :string
  end
end
