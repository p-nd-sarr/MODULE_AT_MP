class AddInfoUser < ActiveRecord::Migration[5.2]
  def change
    add_column :users, :numero_matricule_solde, :string
    add_column :users, :autres_informations_utiles, :string
    add_column :users, :telephone_bureau, :string
    add_column :users, :cni_file, :string
    add_column :users, :image_profile, :string
    add_column :users, :raison_sociale_employeur_actuel, :string
    add_column :users, :certificat_travail_actuel, :string
    add_column :users, :telephone_employeur_actuel, :string
    add_column :users, :raison_sociale_employeur_precedent, :string
    add_column :users, :certificat_travail_precedent, :string
    add_column :users, :telephone_employeur_precedent, :string


  end
end
