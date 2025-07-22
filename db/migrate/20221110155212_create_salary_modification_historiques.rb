class CreateSalaryModificationHistoriques < ActiveRecord::Migration[5.2]
  def change
    create_table :salary_modification_historiques do |t|

      t.text "prenom"
      t.text "nom"
      t.text "numero_piece"
      t.text "profession"
      t.text "genre"
      t.text "addr"
      t.text "phone"
      t.text "date_naissance"

      t.references :psrm_participant
      t.references :user

      t.timestamps
    end
  end
end
