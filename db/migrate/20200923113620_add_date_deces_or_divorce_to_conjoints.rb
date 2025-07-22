class AddDateDecesOrDivorceToConjoints < ActiveRecord::Migration[5.2]
  def change
    add_column :conjoints, :date_divorce, :date
    add_column :conjoints, :date_deces, :date
    
  end
end
