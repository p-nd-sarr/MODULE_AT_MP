class AddConjointToReversionVeuve < ActiveRecord::Migration[5.2]
  def change
    add_reference :reversion_veuves, :conjoint, foreign_key: true, null: true
  end
end
