class CreateAtCodePrimeSalaires < ActiveRecord::Migration[5.2]
  def change
    create_table :at_code_prime_salaires do |t|
      t.string :designation
      t.string :code
      t.boolean :prise_en_compte
      t.float :montant
      t.references :arret_travail, foreign_key: true

      t.timestamps
    end
  end
end
