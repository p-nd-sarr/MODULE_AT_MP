class AddInfosContratToPsrmParticipants < ActiveRecord::Migration[5.2]
  def change
    add_column :psrm_participants, :contrat_en_cours, :string, limit: 3
    add_column :psrm_participants, :date_debut_contrat, :date
    add_column :psrm_participants, :date_fin_contrat, :date
  end
end
