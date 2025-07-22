class CreateEnrolementRegularisationPointages < ActiveRecord::Migration[5.2]
  def change
    create_table :enrolement_regularisation_pointages do |t|
      t.string :workflow_state
      t.datetime :traite_le
      t.integer :traite_par_id

      t.timestamps
    end
  end
end
