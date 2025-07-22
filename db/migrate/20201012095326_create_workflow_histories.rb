class CreateWorkflowHistories < ActiveRecord::Migration[5.2]
  def change
    create_table :workflow_histories do |t|
      t.references :dossier, polymorphic: true, null: false
      t.string :from
      t.string :to, null: false
      t.references :user, foreign_key: false, null: true

      t.timestamps
    end
  end
end
