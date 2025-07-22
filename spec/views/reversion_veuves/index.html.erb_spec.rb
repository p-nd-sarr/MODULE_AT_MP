require 'rails_helper'

RSpec.describe "reversion_veuves/index", type: :view do
  before(:each) do
    assign(:reversion_veuves, [
      ReversionVeuve.create!(
        workflow_state: "Workflow State",
        prenom: "Prenom",
        nom: "Nom",
        lieu_naissance: "Lieu Naissance",
        numero_affiliation: "Numero Affiliation"
      ),
      ReversionVeuve.create!(
        workflow_state: "Workflow State",
        prenom: "Prenom",
        nom: "Nom",
        lieu_naissance: "Lieu Naissance",
        numero_affiliation: "Numero Affiliation"
      )
    ])
  end

  it "renders a list of reversion_veuves" do
    render
    assert_select "tr>td", text: "Workflow State".to_s, count: 2
    assert_select "tr>td", text: "Prenom".to_s, count: 2
    assert_select "tr>td", text: "Nom".to_s, count: 2
    assert_select "tr>td", text: "Lieu Naissance".to_s, count: 2
    assert_select "tr>td", text: "Numero Affiliation".to_s, count: 2
  end
end
