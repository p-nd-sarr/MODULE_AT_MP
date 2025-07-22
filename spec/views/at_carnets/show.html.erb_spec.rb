require 'rails_helper'

RSpec.describe "at_carnets/show", type: :view do
  before(:each) do
    @at_carnet = assign(:at_carnet, AtCarnet.create!(
      numero_carnet: "Numero Carnet",
      arret_travail_id: 2,
      numero_employeur: "Numero Employeur"
    ))
  end

  it "renders attributes in <p>" do
    render
    expect(rendered).to match(/Numero Carnet/)
    expect(rendered).to match(/2/)
    expect(rendered).to match(/Numero Employeur/)
  end
end
