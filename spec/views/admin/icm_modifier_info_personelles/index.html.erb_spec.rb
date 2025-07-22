require 'rails_helper'

RSpec.describe "admin/icm_modifier_info_personelles/index", type: :view do
  before(:each) do
    assign(:admin_icm_modifier_info_personelles, [
      Admin::IcmModifierInfoPersonelle.create!(
        prenom: "Prenom",
        nom: "Nom",
        telephone: "Telephone"
      ),
      Admin::IcmModifierInfoPersonelle.create!(
        prenom: "Prenom",
        nom: "Nom",
        telephone: "Telephone"
      )
    ])
  end

  it "renders a list of admin/icm_modifier_info_personelles" do
    render
    assert_select "tr>td", text: "Prenom".to_s, count: 2
    assert_select "tr>td", text: "Nom".to_s, count: 2
    assert_select "tr>td", text: "Telephone".to_s, count: 2
  end
end
