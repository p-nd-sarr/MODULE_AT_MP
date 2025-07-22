require 'rails_helper'

RSpec.describe "admin/icm_modifier_info_personelles/show", type: :view do
  before(:each) do
    @admin_icm_modifier_info_personelle = assign(:admin_icm_modifier_info_personelle, Admin::IcmModifierInfoPersonelle.create!(
      prenom: "Prenom",
      nom: "Nom",
      telephone: "Telephone"
    ))
  end

  it "renders attributes in <p>" do
    render
    expect(rendered).to match(/Prenom/)
    expect(rendered).to match(/Nom/)
    expect(rendered).to match(/Telephone/)
  end
end
