class AddDateRejetToAtGuerison < ActiveRecord::Migration[5.2]
  def change
    add_column :at_guerisons, :date_rejet, :date
    add_column :at_guerisons, :rejete_par_id, :integer
  end
end
