class AddUserValiderReversion < ActiveRecord::Migration[5.2]
  def change

    add_column :reversion_veuves, :date_soumis, :date

    add_column :reversion_veuves, :ajoute_par_id, :integer
    add_column :reversion_veuves, :ajouter_le, :date

    add_column :reversion_veuves, :affecter_a, :integer
    add_column :reversion_veuves, :affecter_le, :date

    add_column :reversion_veuves, :instruit_par_id, :integer
    add_column :reversion_veuves, :instruit_le, :date

    add_column :reversion_veuves, :valider_par_id, :integer
    add_column :reversion_veuves, :valider_le, :date

  end
end
