require 'rails_helper'

RSpec.describe "admin/demande_carte_allocataires/index", type: :view do
  before(:each) do
    assign(:admin_demande_carte_allocataires, [
      Admin::DemandeCarteAllocataire.create!(
        user: nil,
        numero_document: "Numero Document",
        agence_enregistrement_id: 2,
        nom: "Nom",
        prenom: "Prenom",
        nin: "Nin",
        email: "Email",
        adresse: "Adresse",
        agence_retrait_id: 3,
        telephone: "Telephone"
      ),
      Admin::DemandeCarteAllocataire.create!(
        user: nil,
        numero_document: "Numero Document",
        agence_enregistrement_id: 2,
        nom: "Nom",
        prenom: "Prenom",
        nin: "Nin",
        email: "Email",
        adresse: "Adresse",
        agence_retrait_id: 3,
        telephone: "Telephone"
      )
    ])
  end

  it "renders a list of admin/demande_carte_allocataires" do
    render
    assert_select "tr>td", text: nil.to_s, count: 2
    assert_select "tr>td", text: "Numero Document".to_s, count: 2
    assert_select "tr>td", text: 2.to_s, count: 2
    assert_select "tr>td", text: "Nom".to_s, count: 2
    assert_select "tr>td", text: "Prenom".to_s, count: 2
    assert_select "tr>td", text: "Nin".to_s, count: 2
    assert_select "tr>td", text: "Email".to_s, count: 2
    assert_select "tr>td", text: "Adresse".to_s, count: 2
    assert_select "tr>td", text: 3.to_s, count: 2
    assert_select "tr>td", text: "Telephone".to_s, count: 2
  end
end
