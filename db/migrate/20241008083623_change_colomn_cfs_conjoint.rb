class ChangeColomnCfsConjoint < ActiveRecord::Migration[5.2]
  def change
    rename_column :cfs_conjoints, :numero_immatriculation, :numero_securite_sociale
  end
end
