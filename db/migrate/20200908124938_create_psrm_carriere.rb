class CreatePsrmCarriere < ActiveRecord::Migration[5.2]
  def change
    create_table :psrm_carrieres do |t|
      t.string :matric, limit: 20
      t.string :fhnum, limit: 20
      t.string :prenom, limit: 100
      t.string :nom, limit: 100
      t.string :fhrsoc
      t.string :regime, limit: 5
      t.date :date_debut_contrat
      t.date :date_fin_contrat
      t.string :motif_sortie
      t.date :date_debut_periode_cotisation
      t.date :date_fin_periode_cotisation
      t.float :total_sal_css_atmp_1
      t.float :total_sal_css_atmp_2
      t.float :total_sal_css_atmp_3
      t.float :total_sal_css_pf_1
      t.float :total_sal_css_pf_2
      t.float :total_sal_css_pf_3
      t.float :total_sal_ipres_rg_1
      t.float :total_sal_ipres_rg_2
      t.float :total_sal_ipres_rg_3
      t.float :total_sal_ipres_rcc_1
      t.float :total_sal_ipres_rcc_2
      t.float :total_sal_ipres_rcc_3
    end
  end
end
