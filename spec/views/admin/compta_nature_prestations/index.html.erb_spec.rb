require 'rails_helper'

RSpec.describe "admin/compta_nature_prestations/index", type: :view do
  before(:each) do
    assign(:admin_compta_nature_prestations, [
      Admin::ComptaNaturePrestation.create!(
        code: "Code",
        libelle: "Libelle",
        entite: 2,
        branche: 3
      ),
      Admin::ComptaNaturePrestation.create!(
        code: "Code",
        libelle: "Libelle",
        entite: 2,
        branche: 3
      )
    ])
  end

  it "renders a list of admin/compta_nature_prestations" do
    render
    assert_select "tr>td", text: "Code".to_s, count: 2
    assert_select "tr>td", text: "Libelle".to_s, count: 2
    assert_select "tr>td", text: 2.to_s, count: 2
    assert_select "tr>td", text: 3.to_s, count: 2
  end
end
