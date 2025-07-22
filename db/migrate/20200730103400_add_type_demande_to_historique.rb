class AddTypeDemandeToHistorique < ActiveRecord::Migration[5.2]
  def change
    add_column :historiques, :type_demande, :string
  end
end
