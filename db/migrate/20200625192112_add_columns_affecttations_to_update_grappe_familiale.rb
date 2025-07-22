class AddColumnsAffecttationsToUpdateGrappeFamiliale < ActiveRecord::Migration[5.2]
  def change
    add_column :update_grappe_familiales, :affectation_allocataire, :integer
    add_column :update_grappe_familiales, :affectation_allocataire_date, :datetime
  end
end
