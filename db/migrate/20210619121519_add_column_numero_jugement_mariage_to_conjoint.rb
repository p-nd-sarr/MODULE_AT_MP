class AddColumnNumeroJugementMariageToConjoint < ActiveRecord::Migration[5.2]
  def change
    add_column :conjoints, :numero_jugement_mariage, :string
  end
end
