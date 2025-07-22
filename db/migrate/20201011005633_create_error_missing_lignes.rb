class CreateErrorMissingLignes < ActiveRecord::Migration[5.2]
  def change
    create_table :error_missing_lignes do |t|
      t.string :nom
      t.string :prenom
      t.string :matricule
      t.string :message
      t.references :missing_declaration, foreign_key: true

      t.timestamps
    end
  end
end
