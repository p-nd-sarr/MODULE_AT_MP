class AddColumnNumeroSecuSocialToCafConjoint < ActiveRecord::Migration[5.2]
  def change
    add_column :caf_conjoints, :numero_secu_social, :string
  end
end
