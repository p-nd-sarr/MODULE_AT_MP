class CreateAtEvents < ActiveRecord::Migration[5.2]
  def change
    create_table :at_events do |t|
      t.text :description
      t.string :done_by
      t.references :arret_travail, foreign_key: true

      t.timestamps
    end
  end
end
