class AddEstValideColumnToAtAvis < ActiveRecord::Migration[5.2]
  def change
    add_column :at_avis, :est_valide, :boolean, default: :false
  end
end
