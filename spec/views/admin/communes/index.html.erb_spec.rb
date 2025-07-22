require 'rails_helper'

RSpec.describe "admin/communes/index", type: :view do
  before(:each) do
    assign(:admin_communes, [
      Admin::Commune.create!(
        admin_ville: nil,
        code: 2,
        designation: "Designation"
      ),
      Admin::Commune.create!(
        admin_ville: nil,
        code: 2,
        designation: "Designation"
      )
    ])
  end

  it "renders a list of admin/communes" do
    render
    assert_select "tr>td", text: nil.to_s, count: 2
    assert_select "tr>td", text: 2.to_s, count: 2
    assert_select "tr>td", text: "Designation".to_s, count: 2
  end
end
