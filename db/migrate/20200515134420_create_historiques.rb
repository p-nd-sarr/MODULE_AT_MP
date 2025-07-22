class CreateHistoriques < ActiveRecord::Migration[5.2]
  def change
    create_table :historiques do |t|
      t.date :date_valide
      t.date :date_soumission
      t.date :date_suspension
      t.date :date_reversion
      t.date :date_extinction

      t.timestamps
    end
  end
end
