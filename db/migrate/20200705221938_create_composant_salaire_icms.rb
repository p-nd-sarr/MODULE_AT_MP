class CreateComposantSalaireIcms < ActiveRecord::Migration[5.2]
  def change
    create_table :composant_salaire_icms do |t|
      t.references :at_code_prime_salaire, foreign_key: true
      t.references :dossier_maternite, foreign_key: true
      t.integer :montant

      t.timestamps
    end
  end
end
