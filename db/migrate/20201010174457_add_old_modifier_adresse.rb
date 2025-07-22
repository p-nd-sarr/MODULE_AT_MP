class AddOldModifierAdresse < ActiveRecord::Migration[5.2]
  def change
    add_column :modifier_adresses, :old_adresse_rue, :string
    add_column :modifier_adresses, :old_adresse_ville, :string
  end
end
