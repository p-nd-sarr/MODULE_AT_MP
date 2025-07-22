require 'rails_helper'

RSpec.describe "admin/quartiers/show", type: :view do
  before(:each) do
    @admin_quartier = assign(:admin_quartier, Admin::Quartier.create!(
      admin_commune: nil,
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
