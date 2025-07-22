class CreateSalarieConjoints < ActiveRecord::Migration[5.2]
  def change
    create_table :salarie_conjoints do |t|
      t.references :user, foreign_key: true
      t.string :prenom, null: false
      t.string :nom, null: false
      t.date :date_naissance, null: false
      t.date :date_mariage, null: false
      t.string :nin
      t.integer :etat, default: 1

      t.timestamps
    end
  end
end
