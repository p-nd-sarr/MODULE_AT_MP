class UpdateTableConjointToConjoint < ActiveRecord::Migration[5.2]
  def change
    rename_column :conjoints, :prenom_conjoint, :prenom_salarie
    rename_column :conjoints, :nom_conjoint, :nom_salarie
  end
end
