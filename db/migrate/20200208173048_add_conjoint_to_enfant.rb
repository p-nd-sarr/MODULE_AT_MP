class AddConjointToEnfant < ActiveRecord::Migration[5.2]
  def change
    add_reference :enfants, :conjoint, foreign_key: true
  end
end
