require 'rails_helper'

RSpec.describe "admin/communes/show", type: :view do
  before(:each) do
    @admin_commune = assign(:admin_commune, Admin::Commune.create!(
      admin_ville: nil,
      code: 2,
      designation: "Designation"
    ))
  end

  it "renders attributes in <p>" do
    render
    expect(rendered).to match(//)
    expect(rendered).to match(/2/)
    expect(rendered).to match(/Designation/)
  end
end
