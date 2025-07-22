class CreateIcmModifierInfoPersonnelles < ActiveRecord::Migration[5.2]
  def change
    create_table :icm_modifier_info_personnelles do |t|
      t.integer :dossier_maternite_id
      t.string :prenom
      t.string :nom
      t.string :sexe
      t.string :nin
      t.string :type_piece
      t.date :date_naissance
      t.string :lieu_naissance
      t.string :email
      t.string :telephone
      t.string :adresse_domicile
      t.datetime :debut_grossesse
      t.datetime :debut_conges
      t.datetime :date_suspension_salaire
      t.integer :mode_paiement
      t.integer :etat, default: 0, null: false
      t.integer :ajoute_par_id
      t.timestamps
    end
  end
end
