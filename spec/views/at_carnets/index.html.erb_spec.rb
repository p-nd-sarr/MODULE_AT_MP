require 'rails_helper'

RSpec.describe "at_carnets/index", type: :view do
  before(:each) do
    assign(:at_carnets, [
      AtCarnet.create!(
        numero_carnet: "Numero Carnet",
        arret_travail_id: 2,
        numero_employeur: "Numero Employeur"
      ),
      AtCarnet.create!(
        numero_carnet: "Numero Carnet",
        arret_travail_id: 2,
        numero_employeur: "Numero Employeur"
      )
    ])
  end

  it "renders a list of at_carnets" do
    render
    assert_select "tr>td", text: "Numero Carnet".to_s, count: 2
    assert_select "tr>td", text: 2.to_s, count: 2
    assert_select "tr>td", text: "Numero Employeur".to_s, count: 2
  end
end
