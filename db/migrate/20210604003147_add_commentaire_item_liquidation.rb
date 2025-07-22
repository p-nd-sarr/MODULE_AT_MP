class AddCommentaireItemLiquidation < ActiveRecord::Migration[5.2]
  def change
    add_column :liquidation_retraites, :commentaire_soumission, :string
    add_column :liquidation_retraites, :commentaire_instruction, :string
    add_column :liquidation_retraites, :commentaire_carriere, :string
    add_column :liquidation_retraites, :commentaire_validation_carriere, :string
    add_column :liquidation_retraites, :commentaire_tableau, :string
    add_column :liquidation_retraites, :commentaire_validation_tableau, :string
    add_column :liquidation_retraites, :commentaire_validation, :string
  end
end
