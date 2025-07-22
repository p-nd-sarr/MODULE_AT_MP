require 'rails_helper'

RSpec.describe "admin/villes/index", type: :view do
  before(:each) do
    assign(:admin_villes, [
      Admin::Ville.create!(
        admin_departement: nil,
        code: 2,
        designation: "Designation"
      ),
      Admin::Ville.create!(
        admin_departement: nil,
        code: 2,
        designation: "Designation"
      )
    ])
  end

  it "renders a list of admin/villes" do
    render
    assert_select "tr>td", text: nil.to_s, count: 2
    assert_select "tr>td", text: 2.to_s, count: 2
    assert_select "tr>td", text: "Designation".to_s, count: 2
  end
end
