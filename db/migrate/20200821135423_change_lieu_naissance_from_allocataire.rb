class ChangeLieuNaissanceFromAllocataire < ActiveRecord::Migration[5.2]
  def self.up
    change_column :allocataires, :lieu_naissance, :string
  end

  def self.down
    change_column :allocataires, :lieu_naissance, :string
  end
end
