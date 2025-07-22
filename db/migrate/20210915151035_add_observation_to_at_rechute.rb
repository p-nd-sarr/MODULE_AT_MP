class AddObservationToAtRechute < ActiveRecord::Migration[5.2]
  def change
    add_column :at_rechutes, :observation, :string
    add_column :at_rechutes, :rejete_par_id, :integer
  end
end
