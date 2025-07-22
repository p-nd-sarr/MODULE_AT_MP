class ChangeTypeEtatToStringToDossierPrestation < ActiveRecord::Migration[5.2]
  def change
    change_column :dossier_prestations, :etat, :string
  end
end
