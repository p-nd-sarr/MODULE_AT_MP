require 'rails_helper'

RSpec.describe "admin/regions/index", type: :view do
  before(:each) do
    assign(:admin_regions, [
      Admin::Region.create!(
        designation: "Designation",
        code: 2,
        pays: "Pays"
      ),
      Admin::Region.create!(
        designation: "Designation",
        code: 2,
        pays: "Pays"
      )
    ])
  end

  it "renders a list of admin/regions" do
    render
    assert_select "tr>td", text: "Designation".to_s, count: 2
    assert_select "tr>td", text: 2.to_s, count: 2
    assert_select "tr>td", text: "Pays".to_s, count: 2
  end
end
