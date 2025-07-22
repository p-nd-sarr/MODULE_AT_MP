class AddSoumisParToModifierAdresse < ActiveRecord::Migration[5.2]
  def change
    add_column :modifier_adresses, :soumis_par, :integer
  end
end
