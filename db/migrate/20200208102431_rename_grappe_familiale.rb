class RenameGrappeFamiliale < ActiveRecord::Migration[5.2]
  def change
    rename_table :salarie_enfants, :enfants
    rename_table :salarie_conjoints, :conjoints

    ActiveStorage::Attachment.where(record_type: 'Salarie::Enfant').update_all(record_type: 'Enfant')
    ActiveStorage::Attachment.where(record_type: 'Salarie::Conjoint').update_all(record_type: 'Conjoint')
  end
end
