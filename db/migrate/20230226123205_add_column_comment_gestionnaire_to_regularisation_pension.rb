class AddColumnCommentGestionnaireToRegularisationPension < ActiveRecord::Migration[5.2]
  def change
    add_column :regularisation_pensions, :comment_gestionnaire, :text
  end
end
