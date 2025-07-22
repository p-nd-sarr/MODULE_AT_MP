class AddDateTranscriptionToConjoints < ActiveRecord::Migration[5.2]
  def change
    add_column :conjoints, :date_transcription, :date
    add_column :enfants, :date_transcription, :date
  end
end
