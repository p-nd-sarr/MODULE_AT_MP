class AddColumnConjointFromEcheanceVeuvesCaisseEpouse < ActiveRecord::Migration[5.2]
  def change
    change_column :echeance_veuves_caisse_epouses, :conjoint_id, :integer, using: 'conjoint_id::integer'
  end
end
