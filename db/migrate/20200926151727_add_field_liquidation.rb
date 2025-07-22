class AddFieldLiquidation < ActiveRecord::Migration[5.2]
  def change
    add_column :echeance_paiements, :instruit_par, :integer
    add_column :echeance_paiements, :liquider_par, :integer
    add_column :echeance_paiements, :valider_service_par, :integer
    add_column :echeance_paiements, :valider_chef_section_par, :integer

    add_column :echeance_paiements, :instruit_le, :datetime
    add_column :echeance_paiements, :liquider_le, :datetime
    add_column :echeance_paiements, :valider_service_le, :datetime
    add_column :echeance_paiements, :valider_chef_section_le, :datetime

    add_column :echeance_paiements, :validation_instruction, :boolean
    add_column :echeance_paiements, :validation_liquidation, :boolean

  end
end
