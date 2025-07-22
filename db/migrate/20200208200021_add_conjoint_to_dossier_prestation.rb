class AddConjointToDossierPrestation < ActiveRecord::Migration[5.2]
  def change
    add_reference :dossier_prestations, :conjoint, foreign_key: true
  end
end
