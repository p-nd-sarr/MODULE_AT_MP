class AddColumnDateDecesToMaintienPrestation < ActiveRecord::Migration[5.2]
  def change
    add_column :maintien_prestations, :date_deces, :date
  end
end
