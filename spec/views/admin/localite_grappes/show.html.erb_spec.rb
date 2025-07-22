require 'rails_helper'

RSpec.describe "admin/localite_grappes/show", type: :view do
  before(:each) do
    @admin_localite_grappe = assign(:admin_localite_grappe, Admin::LocaliteGrappe.create!(
      code_pays: 2,
      code_localite: 3,
      localite: "Localite"
    ))
  end

  it "renders attributes in <p>" do
    render
    expect(rendered).to match(/2/)
    expect(rendered).to match(/3/)
    expect(rendered).to match(/Localite/)
  end
end
