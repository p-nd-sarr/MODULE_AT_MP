class AddTypeDemandeToUpdateGrappeFamiliale < ActiveRecord::Migration[5.2]
  def change
    add_column :update_grappe_familiales, :type_demande, :integer
  end
end
