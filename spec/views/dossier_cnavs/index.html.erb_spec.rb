require 'rails_helper'

RSpec.describe "dossier_cnavs/index", type: :view do
  before(:each) do
    assign(:dossier_cnavs, [
      DossierCnav.create!(
        numero_dossier: "Numero Dossier",
        etat: 2,
        mois: 3,
        annee: 4,
        motif_rejet: "Motif Rejet",
        soumis_par_id: 5,
        valide_par_id: 6,
        ajoute_par_id: 7,
        traite_par_id: 8,
        admin_region_id: 9,
        admin_agence_id: 10,
        agence_creation_id: 11,
        user: nil
      ),
      DossierCnav.create!(
        numero_dossier: "Numero Dossier",
        etat: 2,
        mois: 3,
        annee: 4,
        motif_rejet: "Motif Rejet",
        soumis_par_id: 5,
        valide_par_id: 6,
        ajoute_par_id: 7,
        traite_par_id: 8,
        admin_region_id: 9,
        admin_agence_id: 10,
        agence_creation_id: 11,
        user: nil
      )
    ])
  end

  it "renders a list of dossier_cnavs" do
    render
    assert_select "tr>td", text: "Numero Dossier".to_s, count: 2
    assert_select "tr>td", text: 2.to_s, count: 2
    assert_select "tr>td", text: 3.to_s, count: 2
    assert_select "tr>td", text: 4.to_s, count: 2
    assert_select "tr>td", text: "Motif Rejet".to_s, count: 2
    assert_select "tr>td", text: 5.to_s, count: 2
    assert_select "tr>td", text: 6.to_s, count: 2
    assert_select "tr>td", text: 7.to_s, count: 2
    assert_select "tr>td", text: 8.to_s, count: 2
    assert_select "tr>td", text: 9.to_s, count: 2
    assert_select "tr>td", text: 10.to_s, count: 2
    assert_select "tr>td", text: 11.to_s, count: 2
    assert_select "tr>td", text: nil.to_s, count: 2
  end
end
