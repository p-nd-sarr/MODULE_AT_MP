class UpdateLenghtTelephoneOnAllocataire < ActiveRecord::Migration[5.2]
  def change
    change_column :allocataires, :telephone, :string, limit: 100
  end
end
