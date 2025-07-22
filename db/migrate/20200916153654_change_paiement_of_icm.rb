class ChangePaiementOfIcm < ActiveRecord::Migration[5.2]
  def change
    remove_column :indemnite_conges_maternites, :paiement

    add_column :indemnite_conges_maternites, :paiement, :boolean, :default => false, :null => false
    add_column :indemnite_conges_maternites, :rapport_controle, :string
    add_column :indemnite_conges_maternites, :impot_ir, :float
    add_column :indemnite_conges_maternites, :impot_trimf, :float
    add_column :indemnite_conges_maternites, :lieu_accouchement, :string

    add_column :dossier_maternites, :cloture, :boolean, :default => false

  end
end
