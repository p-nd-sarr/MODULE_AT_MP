class AddInfoToRentier < ActiveRecord::Migration[5.2]
  def change
    add_column :rentiers, :date_consolidation, :date
    add_column :rentiers, :date_depart_rente, :date
    add_column :rentiers, :date_deces, :date
    add_column :rentiers, :date_liquidation, :date
    add_column :rentiers, :date_activation_dg, :date
    add_column :rentiers, :date_rejet, :date
    add_column :rentiers, :date_suspension, :date
    add_column :rentiers, :date_eteint, :date
    add_column :rentiers, :date_activation_dir_at, :date
    add_column :rentiers, :taux_ipp_retenu, :integer
    add_column :rentiers, :montant_rente_mensuel, :integer
    add_column :rentiers, :montant_rente_trimestre, :integer
    add_column :rentiers, :type_rente, :string
    add_column :rentiers, :montant_versement_unique, :integer
    add_column :rentiers, :montant_majoration, :integer
    add_column :rentiers, :rente_majoree, :integer
    add_column :rentiers, :numero_sinistre, :string
    add_column :rentiers, :capital_rente, :integer
    add_column :rentiers, :motif_rejet, :text
    add_column :rentiers, :rejete_par, :integer
  end
end
