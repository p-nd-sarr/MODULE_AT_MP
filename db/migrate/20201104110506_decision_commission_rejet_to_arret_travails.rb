class DecisionCommissionRejetToArretTravails < ActiveRecord::Migration[5.2]
  def change
    add_column :arret_travails, :decision_commission_rejet, :string
  end
end
