require 'rails_helper'

RSpec.describe "admin/deces_enfants/show", type: :view do
  before(:each) do
    @admin_deces_enfant = assign(:admin_deces_enfant, Admin::DecesEnfant.create!(
      numero_affiliation: "",
      prenom: "",
      nom: "",
      date_naissance: "",
      date_deces,: "Date Deces,",
      prenom_salarie: "",
      nom_salarie: "",
      type_piece: "",
      numero_piece: "Numero Piece"
    ))
  end

  it "renders attributes in <p>" do
    render
    expect(rendered).to match(//)
    expect(rendered).to match(//)
    expect(rendered).to match(//)
    expect(rendered).to match(//)
    expect(rendered).to match(/Date Deces,/)
    expect(rendered).to match(//)
    expect(rendered).to match(//)
    expect(rendered).to match(//)
    expect(rendered).to match(/Numero Piece/)
  end
end
