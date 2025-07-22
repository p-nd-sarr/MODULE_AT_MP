require 'rails_helper'

RSpec.describe "admin/deces_enfants/index", type: :view do
  before(:each) do
    assign(:admin_deces_enfants, [
      Admin::DecesEnfant.create!(
        numero_affiliation: "",
        prenom: "",
        nom: "",
        date_naissance: "",
        date_deces,: "Date Deces,",
        prenom_salarie: "",
        nom_salarie: "",
        type_piece: "",
        numero_piece: "Numero Piece"
      ),
      Admin::DecesEnfant.create!(
        numero_affiliation: "",
        prenom: "",
        nom: "",
        date_naissance: "",
        date_deces,: "Date Deces,",
        prenom_salarie: "",
        nom_salarie: "",
        type_piece: "",
        numero_piece: "Numero Piece"
      )
    ])
  end

  it "renders a list of admin/deces_enfants" do
    render
    assert_select "tr>td", text: "".to_s, count: 2
    assert_select "tr>td", text: "".to_s, count: 2
    assert_select "tr>td", text: "".to_s, count: 2
    assert_select "tr>td", text: "".to_s, count: 2
    assert_select "tr>td", text: "Date Deces,".to_s, count: 2
    assert_select "tr>td", text: "".to_s, count: 2
    assert_select "tr>td", text: "".to_s, count: 2
    assert_select "tr>td", text: "".to_s, count: 2
    assert_select "tr>td", text: "Numero Piece".to_s, count: 2
  end
end
