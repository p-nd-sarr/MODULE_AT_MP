class CreateGrossesses < ActiveRecord::Migration[5.2]
  def change
    create_table :grossesses do |t|
      t.references :dossier_prestation, foreign_key: true, null: false
      t.date :date_grossesse, null: false
      t.integer :etat, null: false, default: 1

      t.timestamps
    end
  end
end
