class AddDateOuvertureToReversionVeuve < ActiveRecord::Migration[5.2]
  def change
    add_column :reversion_veuves, :date_ouverture, :date
    add_column :dossier_reversion_salaries, :date_ouverture, :date
    add_column :base_reversion_salaries, :date_ouverture, :date
  end
end
