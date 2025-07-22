class AddNombreAyantDroitToBaseReversion < ActiveRecord::Migration[5.2]
  def change
    add_column :base_reversions, :nombre_epouses_eligible, :integer
    add_column :base_reversions, :nombre_enfant_eligible, :integer

    BaseReversion.all.each { |base_reversion|
      base_reversion.nombre_epouses_eligible = base_reversion.reversion_veuves.veuve.eligibles.count
      base_reversion.nombre_enfant_eligible = base_reversion.reversion_veuves.orphelin.eligibles.count

      base_reversion.save(validate: false)
    }

    change_column_null :base_reversions, :nombre_epouses_eligible, false
    change_column_null :base_reversions, :nombre_enfant_eligible, false
  end
end
