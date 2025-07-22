class AddColumnSupToMaintienPrestation < ActiveRecord::Migration[5.2]
  def change
    add_column :maintien_prestations, :date_arret_activite, :date
  end
end
