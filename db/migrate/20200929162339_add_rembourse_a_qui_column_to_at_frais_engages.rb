class AddRembourseAQuiColumnToAtFraisEngages < ActiveRecord::Migration[5.2]
  def change
    add_column :at_frais_engages, :rembourse_a_qui, :integer, default: 1
  end
end
