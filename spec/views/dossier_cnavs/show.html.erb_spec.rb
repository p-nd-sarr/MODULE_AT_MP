require 'rails_helper'

RSpec.describe "dossier_cnavs/show", type: :view do
  before(:each) do
    @dossier_cnav = assign(:dossier_cnav, DossierCnav.create!(
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
    ))
  end

  it "renders attributes in <p>" do
    render
    expect(rendered).to match(/Numero Dossier/)
    expect(rendered).to match(/2/)
    expect(rendered).to match(/3/)
    expect(rendered).to match(/4/)
    expect(rendered).to match(/Motif Rejet/)
    expect(rendered).to match(/5/)
    expect(rendered).to match(/6/)
    expect(rendered).to match(/7/)
    expect(rendered).to match(/8/)
    expect(rendered).to match(/9/)
    expect(rendered).to match(/10/)
    expect(rendered).to match(/11/)
    expect(rendered).to match(//)
  end
end
