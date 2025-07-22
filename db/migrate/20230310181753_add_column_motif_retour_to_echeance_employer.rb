class AddColumnMotifRetourToEcheanceEmployer < ActiveRecord::Migration[5.2]
  def change
    add_column :echeance_caisse_employeurs, :motif_retour, :text
  end
end
