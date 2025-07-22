class AddInfoEtatCivilGenaredToConjoint < ActiveRecord::Migration[5.2]
  def change
    add_column :conjoints, :code_etat_civil, :string
    add_column :conjoints, :numero_registre, :integer
    add_column :conjoints, :nin_generer, :string
  end
end
