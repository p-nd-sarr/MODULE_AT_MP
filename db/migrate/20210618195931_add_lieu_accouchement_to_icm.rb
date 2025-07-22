class AddLieuAccouchementToIcm < ActiveRecord::Migration[5.2]
  def change
    remove_column :indemnite_conges_maternites, :lieu_accouchement, :string
    add_column :indemnite_conges_maternites, :lieu_accouchement, :integer


    add_column :indemnite_conges_maternites, :date_rapport, :datetime
  end
end
