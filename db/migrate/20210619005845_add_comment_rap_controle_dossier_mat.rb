class AddCommentRapControleDossierMat < ActiveRecord::Migration[5.2]
  def change
    add_column :dossier_maternites, :commentaire_affectation_controleur, :string
  end
end
