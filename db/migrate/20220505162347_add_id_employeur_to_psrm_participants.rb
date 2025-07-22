class AddIdEmployeurToPsrmParticipants < ActiveRecord::Migration[5.2]
  def change
    add_column :psrm_participants, :id_employeur, :string, limit: 20
    add_index :psrm_participants, :id_employeur
  end
end
