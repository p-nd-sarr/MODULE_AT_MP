class AddDateDeclarationToDeclarationDivorceOuDecesConjoint < ActiveRecord::Migration[5.2]
  def change
    add_column :declaration_divorce_ou_deces_conjoints, :date_declaration, :date
  end
end
