require 'rails_helper'

RSpec.describe "admin/regions/show", type: :view do
  before(:each) do
    @admin_region = assign(:admin_region, Admin::Region.create!(
      designation: "Designation",
      code: 2,
      pays: "Pays"
    ))
  end

  it "renders attributes in <p>" do
    render
    expect(rendered).to match(/Designation/)
    expect(rendered).to match(/2/)
    expect(rendered).to match(/Pays/)
  end
end
