class AddColumnpfToAllocataire < ActiveRecord::Migration[5.2]
  def change
    add_column :allocataires, :lieu_naissance, :date
    add_column :allocataires, :regime_mat, :int
    add_column :allocataires, :type_residence, :int
    add_column :allocataires, :numero_employeur, :string
    add_column :allocataires, :adress_employeur, :string
  end
end
