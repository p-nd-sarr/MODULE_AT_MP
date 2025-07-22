require 'rails_helper'

RSpec.describe "admin/compta_nature_prestations/show", type: :view do
  before(:each) do
    @admin_compta_nature_prestation = assign(:admin_compta_nature_prestation, Admin::ComptaNaturePrestation.create!(
      code: "Code",
      libelle: "Libelle",
      entite: 2,
      branche: 3
    ))
  end

  it "renders attributes in <p>" do
    render
    expect(rendered).to match(/Code/)
    expect(rendered).to match(/Libelle/)
    expect(rendered).to match(/2/)
    expect(rendered).to match(/3/)
  end
end
