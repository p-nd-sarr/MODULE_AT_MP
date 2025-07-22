class AddInfosLiquidation2ToAllocataire < ActiveRecord::Migration[5.2]
  def change
    add_column :allocataires, :moyenne, :float, default: 0
    add_column :allocataires, :mois_gratuis, :float, default: 0
    add_column :allocataires, :points, :float, default: 0
    add_column :allocataires, :points_base, :float, default: 0
    add_column :allocataires, :point_minoration, :float, default: 0
    add_column :allocataires, :pourcentage_majoration, :float, default: 0
    add_column :allocataires, :point_majoration, :float, default: 0
    add_column :allocataires, :points_complementaires, :float, default: 0
    add_column :allocataires, :points_servis, :float, default: 0
    add_column :allocataires, :montant_imposable, :float, default: 0
  end
end
