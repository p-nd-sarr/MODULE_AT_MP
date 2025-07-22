require 'rails_helper'

RSpec.describe "admin/demande_carte_allocataires/show", type: :view do
  before(:each) do
    @admin_demande_carte_allocataire = assign(:admin_demande_carte_allocataire, Admin::DemandeCarteAllocataire.create!(
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
    ))
  end

  it "renders attributes in <p>" do
    render
    expect(rendered).to match(//)
    expect(rendered).to match(/Numero Document/)
    expect(rendered).to match(/2/)
    expect(rendered).to match(/Nom/)
    expect(rendered).to match(/Prenom/)
    expect(rendered).to match(/Nin/)
    expect(rendered).to match(/Email/)
    expect(rendered).to match(/Adresse/)
    expect(rendered).to match(/3/)
    expect(rendered).to match(/Telephone/)
  end
end
