require 'rails_helper'

RSpec.describe "admin/deces_salaries/show", type: :view do
  before(:each) do
    @admin_deces_salarie = assign(:admin_deces_salarie, Admin::DecesSalarie.create!(
      numero_affiliation: "Numero Affiliation",
      prenom: "Prenom",
      nom: "Nom",
      numero_piece: "Numero Piece"
    ))
  end

  it "renders attributes in <p>" do
    render
    expect(rendered).to match(/Numero Affiliation/)
    expect(rendered).to match(/Prenom/)
    expect(rendered).to match(/Nom/)
    expect(rendered).to match(/Numero Piece/)
  end
end
