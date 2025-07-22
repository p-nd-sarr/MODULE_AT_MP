require 'rails_helper'

RSpec.describe "dossier_cnavs/edit", type: :view do
  before(:each) do
    @dossier_cnav = assign(:dossier_cnav, DossierCnav.create!(
      numero_dossier: "MyString",
      etat: 1,
      mois: 1,
      annee: 1,
      motif_rejet: "MyString",
      soumis_par_id: 1,
      valide_par_id: 1,
      ajoute_par_id: 1,
      traite_par_id: 1,
      admin_region_id: 1,
      admin_agence_id: 1,
      agence_creation_id: 1,
      user: nil
    ))
  end

  it "renders the edit dossier_cnav form" do
    render

    assert_select "form[action=?][method=?]", dossier_cnav_path(@dossier_cnav), "post" do

      assert_select "input[name=?]", "dossier_cnav[numero_dossier]"

      assert_select "input[name=?]", "dossier_cnav[etat]"

      assert_select "input[name=?]", "dossier_cnav[mois]"

      assert_select "input[name=?]", "dossier_cnav[annee]"

      assert_select "input[name=?]", "dossier_cnav[motif_rejet]"

      assert_select "input[name=?]", "dossier_cnav[soumis_par_id]"

      assert_select "input[name=?]", "dossier_cnav[valide_par_id]"

      assert_select "input[name=?]", "dossier_cnav[ajoute_par_id]"

      assert_select "input[name=?]", "dossier_cnav[traite_par_id]"

      assert_select "input[name=?]", "dossier_cnav[admin_region_id]"

      assert_select "input[name=?]", "dossier_cnav[admin_agence_id]"

      assert_select "input[name=?]", "dossier_cnav[agence_creation_id]"

      assert_select "input[name=?]", "dossier_cnav[user_id]"
    end
  end
end
