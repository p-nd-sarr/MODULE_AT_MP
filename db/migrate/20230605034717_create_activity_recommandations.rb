class CreateActivityRecommandations < ActiveRecord::Migration[5.2]
  def change
    create_table :activity_recommandations do |t|
      t.integer :ajoute_par_id
      t.integer :affecte_a_id
      t.integer :response_par_id
      t.text :recommandation
      t.text :direction_response
      t.date :date_response
      t.references :dossier_audits, foreign_key: true
      t.references :dossier_audit_activities, foreign_key: true

      t.timestamps
    end
  end
end
