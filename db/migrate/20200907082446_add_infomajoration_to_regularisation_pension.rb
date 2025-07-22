class AddInfomajorationToRegularisationPension < ActiveRecord::Migration[5.2]
  def change
    add_column :regularisation_pensions, :pourcentage_majoration, :float, default: 0
    add_column :regularisation_pensions, :nb_enfant_a_regulariser, :integer, default: 0
    add_column :regularisation_pensions, :nb_mois_retournes, :integer, default: 0
    
  end
end
