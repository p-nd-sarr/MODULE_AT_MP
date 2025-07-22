class AddJugementPalimentaire < ActiveRecord::Migration[5.2]
  def change

    add_column :pension_alimentaires, :numero_jugement, :string
    add_column :pension_alimentaires, :montant_versement, :float
  end
end
