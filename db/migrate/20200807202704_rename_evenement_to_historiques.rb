class RenameEvenementToHistoriques < ActiveRecord::Migration[5.2]
  def change
    rename_column :historiques, :type_demande, :evenement
  end
end
