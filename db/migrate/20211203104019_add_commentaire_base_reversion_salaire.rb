class AddCommentaireBaseReversionSalaire < ActiveRecord::Migration[5.2]
  def change
    add_column :base_reversion_salaries, :commentaire_soumission, :string
    add_column :base_reversion_salaries, :commentaire_instruction, :string
    add_column :base_reversion_salaries, :commentaire_carriere, :string
    add_column :base_reversion_salaries, :commentaire_validation_carriere, :string
    add_column :base_reversion_salaries, :commentaire_tableau, :string
    add_column :base_reversion_salaries, :commentaire_validation_tableau, :string
    add_column :base_reversion_salaries, :commentaire_validation, :string
    add_column :base_reversion_salaries, :commentaire_affectation_salaire, :string
    add_column :base_reversion_salaries, :commentaire_affectation_allocataire, :string
  end
end
