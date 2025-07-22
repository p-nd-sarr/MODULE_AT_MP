class AddColumnNumeroSecuSocialAndNinConjointToCafEnfant < ActiveRecord::Migration[5.2]
  def change
    add_column :caf_enfants, :numero_secu_social, :string
    add_column :caf_enfants, :nin_conjoint, :string
  end
end
