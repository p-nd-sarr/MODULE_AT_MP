class AddColummnIsBeneficiaryToCafConjoint < ActiveRecord::Migration[5.2]
  def change
    add_column :caf_conjoints, :is_beneficiary, :boolean, :default => FALSE
  end
end
