class CreateDeclarationDivorceOuDecesConjoints < ActiveRecord::Migration[5.2]
  def change
    create_table :declaration_divorce_ou_deces_conjoints do |t|
      t.string :numero_affiliation
      t.string :prenom_salarie
      t.string :nom_salarie
      t.integer :status_with_conjoint
      t.string :prenom_conjoint
      t.string :nom_conjoint
      t.integer :type_piece
      t.string :numero_piece_conjoint

      t.references :conjoint
      t.timestamps
    end
  end
end
