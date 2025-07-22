class AddTempsPresenceToPrsmCarriere < ActiveRecord::Migration[5.2]
  def change
    add_column :psrm_carrieres, :temps_travail_1, :string, limit: 20
    add_column :psrm_carrieres, :temps_travail_2, :string, limit: 20
    add_column :psrm_carrieres, :temps_travail_3, :string, limit: 20
    add_column :psrm_carrieres, :temps_presence_jour_1, :float
    add_column :psrm_carrieres, :temps_presence_jour_2, :float
    add_column :psrm_carrieres, :temps_presence_jour_3, :float
    add_column :psrm_carrieres, :temps_presence_heures_1, :float
    add_column :psrm_carrieres, :temps_presence_heures_2, :float
    add_column :psrm_carrieres, :temps_presence_heures_3, :float
  end
end
