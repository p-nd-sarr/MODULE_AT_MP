require 'rails_helper'

RSpec.describe "admin/departements/index", type: :view do
  before(:each) do
    assign(:admin_departements, [
      Admin::Departement.create!(
        region: nil,
        designation: "Designation",
        code: 2
      ),
      Admin::Departement.create!(
        region: nil,
        designation: "Designation",
        code: 2
      )
    ])
  end

  it "renders a list of admin/departements" do
    render
    assert_select "tr>td", text: nil.to_s, count: 2
    assert_select "tr>td", text: "Designation".to_s, count: 2
    assert_select "tr>td", text: 2.to_s, count: 2
  end
end
