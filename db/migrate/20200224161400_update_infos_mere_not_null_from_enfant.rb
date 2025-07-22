class UpdateInfosMereNotNullFromEnfant < ActiveRecord::Migration[5.2]
  def change
    change_column_null :enfants, :prenom_mere, true
    change_column_null :enfants, :nom_mere, true
  end
end
