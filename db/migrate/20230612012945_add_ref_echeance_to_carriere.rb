class AddRefEcheanceToCarriere < ActiveRecord::Migration[5.2]
  def change
    add_reference :carriere_dossier_prestations, :echeance_caisse, foreign_key: true
  end
end
