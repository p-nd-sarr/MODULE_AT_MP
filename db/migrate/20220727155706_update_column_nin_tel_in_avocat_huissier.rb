class UpdateColumnNinTelInAvocatHuissier < ActiveRecord::Migration[5.2]
  def change
    change_column :avocats_huissiers, :nin, 'integer USING CAST(nin AS integer)'
    change_column :avocats_huissiers, :tel, 'integer USING CAST(tel AS integer)'
  end
end
