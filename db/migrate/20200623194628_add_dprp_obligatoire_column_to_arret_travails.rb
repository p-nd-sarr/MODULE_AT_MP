class AddDprpObligatoireColumnToArretTravails < ActiveRecord::Migration[5.2]
  def change
    add_column :arret_travails, :dprp_obligatoire, :boolean, default: :false
  end
end
