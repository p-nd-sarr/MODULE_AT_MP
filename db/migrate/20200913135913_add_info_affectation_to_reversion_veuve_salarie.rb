class AddInfoAffectationToReversionVeuveSalarie < ActiveRecord::Migration[5.2]
  def change
    add_column :reversion_veuve_salaries, :affecter_salarie, :integer
  end
end
