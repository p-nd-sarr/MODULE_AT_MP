require 'rails_helper'

RSpec.describe "allocataire_cnavs/index", type: :view do
  before(:each) do
    assign(:allocataire_cnavs, [
      AllocataireCnav.create!(
        dossier_cnav: nil,
        numero: "Numero",
        prenom: "Prenom",
        nom: "Nom",
        admin_region_id: 2,
        montant: 3,
        origine: "Origine",
        compte: "Compte",
        caisse_bk: 4,
        valide_par_id: 5,
        user: nil,
        ajoute_par_id: 6,
        traite_par_id: 7,
        motif_rejet: "Motif Rejet",
        montant_paiement: 8,
        paiement: false,
        etat: 9,
        mode_paiement: 10,
        numero_liquidation: "Numero Liquidation"
      ),
      AllocataireCnav.create!(
        dossier_cnav: nil,
        numero: "Numero",
        prenom: "Prenom",
        nom: "Nom",
        admin_region_id: 2,
        montant: 3,
        origine: "Origine",
        compte: "Compte",
        caisse_bk: 4,
        valide_par_id: 5,
        user: nil,
        ajoute_par_id: 6,
        traite_par_id: 7,
        motif_rejet: "Motif Rejet",
        montant_paiement: 8,
        paiement: false,
        etat: 9,
        mode_paiement: 10,
        numero_liquidation: "Numero Liquidation"
      )
    ])
  end

  it "renders a list of allocataire_cnavs" do
    render
    assert_select "tr>td", text: nil.to_s, count: 2
    assert_select "tr>td", text: "Numero".to_s, count: 2
    assert_select "tr>td", text: "Prenom".to_s, count: 2
    assert_select "tr>td", text: "Nom".to_s, count: 2
    assert_select "tr>td", text: 2.to_s, count: 2
    assert_select "tr>td", text: 3.to_s, count: 2
    assert_select "tr>td", text: "Origine".to_s, count: 2
    assert_select "tr>td", text: "Compte".to_s, count: 2
    assert_select "tr>td", text: 4.to_s, count: 2
    assert_select "tr>td", text: 5.to_s, count: 2
    assert_select "tr>td", text: nil.to_s, count: 2
    assert_select "tr>td", text: 6.to_s, count: 2
    assert_select "tr>td", text: 7.to_s, count: 2
    assert_select "tr>td", text: "Motif Rejet".to_s, count: 2
    assert_select "tr>td", text: 8.to_s, count: 2
    assert_select "tr>td", text: false.to_s, count: 2
    assert_select "tr>td", text: 9.to_s, count: 2
    assert_select "tr>td", text: 10.to_s, count: 2
    assert_select "tr>td", text: "Numero Liquidation".to_s, count: 2
  end
end
