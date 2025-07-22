class AddCommentaireItem2Liquidation < ActiveRecord::Migration[5.2]
  def change
    add_column :liquidation_retraites, :commentaire_affectation_salaire, :string
    add_column :liquidation_retraites, :commentaire_affectation_allocataire, :string


  end
end
