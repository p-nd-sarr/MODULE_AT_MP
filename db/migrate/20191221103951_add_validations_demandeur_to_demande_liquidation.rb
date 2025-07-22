class AddValidationsDemandeurToDemandeLiquidation < ActiveRecord::Migration[5.2]
  def change
    add_column :liquidation_retraites, :etat_civil_demandeur_valide, :boolean, null: false, default: false
    add_column :liquidation_retraites, :epouses_valide, :boolean, null: false, default: false
    add_column :liquidation_retraites, :enfants_valide, :boolean, null: false, default: false
    add_column :liquidation_retraites, :carriere_valide, :boolean, null: false, default: false
    add_column :liquidation_retraites, :documents_valide, :boolean, null: false, default: false
  end
end
