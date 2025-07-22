class CreateEcheancePaiements < ActiveRecord::Migration[5.2]
  def change
    create_table :echeance_paiements do |t|
      t.integer :annee
      t.integer :periode, default: 1
      t.integer :numero_periode

      t.timestamps
    end
  end
end
