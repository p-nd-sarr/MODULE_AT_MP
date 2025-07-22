class UpdateContratEnCoursFromPsrmParticiptants < ActiveRecord::Migration[5.2]
  def change
    change_column :psrm_participants, :contrat_en_cours, :string, limit: 20
  end
end
