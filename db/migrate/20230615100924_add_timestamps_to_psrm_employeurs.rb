class AddTimestampsToPsrmEmployeurs < ActiveRecord::Migration[5.2]
  def change
    add_column :psrm_employeurs, :created_at, :datetime
    add_column :psrm_employeurs, :updated_at, :datetime
  end
end
