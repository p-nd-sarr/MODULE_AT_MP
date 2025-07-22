class AddInfosTuteurToReversionVeuve < ActiveRecord::Migration[5.2]
  def change
    add_column :reversion_veuves, :nom_tuteur, :string
    add_column :reversion_veuves, :prenom_tuteur, :string
  end
end
