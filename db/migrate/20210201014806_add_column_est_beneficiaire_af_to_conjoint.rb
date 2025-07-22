class AddColumnEstBeneficiaireAfToConjoint < ActiveRecord::Migration[5.2]
  def change
    add_column :conjoints, :est_af_beneficiaire, :boolean
  end
end
