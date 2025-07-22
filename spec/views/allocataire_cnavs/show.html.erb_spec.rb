require 'rails_helper'

RSpec.describe "allocataire_cnavs/show", type: :view do
  before(:each) do
    @allocataire_cnav = assign(:allocataire_cnav, AllocataireCnav.create!(
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
    ))
  end

  it "renders attributes in <p>" do
    render
    expect(rendered).to match(//)
    expect(rendered).to match(/Numero/)
    expect(rendered).to match(/Prenom/)
    expect(rendered).to match(/Nom/)
    expect(rendered).to match(/2/)
    expect(rendered).to match(/3/)
    expect(rendered).to match(/Origine/)
    expect(rendered).to match(/Compte/)
    expect(rendered).to match(/4/)
    expect(rendered).to match(/5/)
    expect(rendered).to match(//)
    expect(rendered).to match(/6/)
    expect(rendered).to match(/7/)
    expect(rendered).to match(/Motif Rejet/)
    expect(rendered).to match(/8/)
    expect(rendered).to match(/false/)
    expect(rendered).to match(/9/)
    expect(rendered).to match(/10/)
    expect(rendered).to match(/Numero Liquidation/)
  end
end
