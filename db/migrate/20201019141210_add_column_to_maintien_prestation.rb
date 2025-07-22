class AddColumnToMaintienPrestation < ActiveRecord::Migration[5.2]
  def change
    add_column :maintien_prestations, :commentaire, :string
  end
end
