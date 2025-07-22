class AddPartTrimfToDossierMaternite < ActiveRecord::Migration[5.2]
  def change
    add_column :dossier_maternites, :part_trimf, :integer
  end
end
