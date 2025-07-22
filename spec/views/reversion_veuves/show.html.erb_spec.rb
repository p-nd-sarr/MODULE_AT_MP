require 'rails_helper'

RSpec.describe "reversion_veuves/show", type: :view do
  before(:each) do
    @reversion_veuve = assign(:reversion_veuve, ReversionVeuve.create!(
      workflow_state: "Workflow State",
      prenom: "Prenom",
      nom: "Nom",
      lieu_naissance: "Lieu Naissance",
      numero_affiliation: "Numero Affiliation"
    ))
  end

  it "renders attributes in <p>" do
    render
    expect(rendered).to match(/Workflow State/)
    expect(rendered).to match(/Prenom/)
    expect(rendered).to match(/Nom/)
    expect(rendered).to match(/Lieu Naissance/)
    expect(rendered).to match(/Numero Affiliation/)
  end
end
