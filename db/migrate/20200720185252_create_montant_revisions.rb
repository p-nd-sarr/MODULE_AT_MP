class CreateMontantRevisions < ActiveRecord::Migration[5.2]
  def change
    create_table :montant_revisions do |t|
      t.integer :annee
      t.integer :point_revision
      t.float :valeur_point_annuel
      t.float :montant_revision
      t.integer :revision_pension_id
      t.integer :type_regime_id

      t.timestamps
    end
  end
end
