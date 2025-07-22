require 'rails_helper'

RSpec.describe "admin/icm_modifier_info_personelles/edit", type: :view do
  before(:each) do
    @admin_icm_modifier_info_personelle = assign(:admin_icm_modifier_info_personelle, Admin::IcmModifierInfoPersonelle.create!(
      prenom: "MyString",
      nom: "MyString",
      telephone: "MyString"
    ))
  end

  it "renders the edit admin_icm_modifier_info_personelle form" do
    render

    assert_select "form[action=?][method=?]", admin_icm_modifier_info_personelle_path(@admin_icm_modifier_info_personelle), "post" do

      assert_select "input[name=?]", "admin_icm_modifier_info_personelle[prenom]"

      assert_select "input[name=?]", "admin_icm_modifier_info_personelle[nom]"

      assert_select "input[name=?]", "admin_icm_modifier_info_personelle[telephone]"
    end
  end
end
