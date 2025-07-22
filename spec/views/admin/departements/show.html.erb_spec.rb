require 'rails_helper'

RSpec.describe "admin/departements/show", type: :view do
  before(:each) do
    @admin_departement = assign(:admin_departement, Admin::Departement.create!(
      region: nil,
      designation: "Designation",
      code: 2
    ))
  end

  it "renders attributes in <p>" do
    render
    expect(rendered).to match(//)
    expect(rendered).to match(/Designation/)
    expect(rendered).to match(/2/)
  end
end
