class AddLieuNaissanceToEnfant < ActiveRecord::Migration[5.2]
  def change
    add_column :enfants, :lieu_naissance, :string
  end
end
