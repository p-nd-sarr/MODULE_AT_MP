require 'rails_helper'

RSpec.describe "admin/deces_salaries/index", type: :view do
  before(:each) do
    assign(:admin_deces_salaries, [
      Admin::DecesSalarie.create!(
        numero_affiliation: "Numero Affiliation",
        prenom: "Prenom",
        nom: "Nom",
        numero_piece: "Numero Piece"
      ),
      Admin::DecesSalarie.create!(
        numero_affiliation: "Numero Affiliation",
        prenom: "Prenom",
        nom: "Nom",
        numero_piece: "Numero Piece"
      )
    ])
  end

  it "renders a list of admin/deces_salaries" do
    render
    assert_select "tr>td", text: "Numero Affiliation".to_s, count: 2
    assert_select "tr>td", text: "Prenom".to_s, count: 2
    assert_select "tr>td", text: "Nom".to_s, count: 2
    assert_select "tr>td", text: "Numero Piece".to_s, count: 2
  end
end
