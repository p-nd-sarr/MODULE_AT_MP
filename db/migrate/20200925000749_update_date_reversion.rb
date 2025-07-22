class UpdateDateReversion < ActiveRecord::Migration[5.2]
  def change
    change_column :reversion_veuves, :ajouter_le, :datetime
    change_column :reversion_veuves, :date_soumis, :datetime
    change_column :reversion_veuves, :affecter_le, :datetime
    change_column :reversion_veuves, :instruit_le, :datetime
    change_column :reversion_veuves, :valider_le, :datetime
  end
end
