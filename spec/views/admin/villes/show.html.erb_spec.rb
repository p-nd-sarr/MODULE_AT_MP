require 'rails_helper'

RSpec.describe "admin/villes/show", type: :view do
  before(:each) do
    @admin_ville = assign(:admin_ville, Admin::Ville.create!(
      admin_departement: nil,
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
