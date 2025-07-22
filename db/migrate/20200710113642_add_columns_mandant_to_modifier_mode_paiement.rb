class AddColumnsMandantToModifierModePaiement < ActiveRecord::Migration[5.2]
  def change
    add_column :modifier_mode_paiements, :adresse_domicile, :string
    add_column :modifier_mode_paiements, :telephone, :string
    add_column :modifier_mode_paiements, :numero_identification_nationale, :string
    add_column :modifier_mode_paiements, :date_debut_changement, :date
  end
end
