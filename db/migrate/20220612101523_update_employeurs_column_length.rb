class UpdateEmployeursColumnLength < ActiveRecord::Migration[5.2]
  def change
    change_column :psrm_employeurs, :ancien_num_css, :string, limit: 100
    change_column :psrm_employeurs, :fhrsoc, :string, limit: 254
    change_column :psrm_employeurs, :fhbp, :string, limit: 100
    change_column :psrm_employeurs, :fhtel, :string, limit: 100
    add_column :psrm_employeurs, :code_agence_css, :string, limit: 50
    add_column :psrm_employeurs, :code_agence_ipres, :string, limit: 50
    add_column :psrm_employeurs, :description_agence_css, :string, limit: 100
    add_column :psrm_employeurs, :description_agence_ipres, :string, limit: 100
  end
end
