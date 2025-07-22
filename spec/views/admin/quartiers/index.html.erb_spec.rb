require 'rails_helper'

RSpec.describe "admin/quartiers/index", type: :view do
  before(:each) do
    assign(:admin_quartiers, [
      Admin::Quartier.create!(
        admin_commune: nil,
        code: 2,
        designation: "Designation"
      ),
      Admin::Quartier.create!(
        admin_commune: nil,
        code: 2,
        designation: "Designation"
      )
    ])
  end

  it "renders a list of admin/quartiers" do
    render
    assert_select "tr>td", text: nil.to_s, count: 2
    assert_select "tr>td", text: 2.to_s, count: 2
    assert_select "tr>td", text: "Designation".to_s, count: 2
  end
end
