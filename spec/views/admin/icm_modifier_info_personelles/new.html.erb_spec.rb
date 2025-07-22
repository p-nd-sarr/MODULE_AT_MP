require 'rails_helper'

RSpec.describe "admin/icm_modifier_info_personelles/new", type: :view do
  before(:each) do
    assign(:admin_icm_modifier_info_personelle, Admin::IcmModifierInfoPersonelle.new(
      prenom: "MyString",
      nom: "MyString",
      telephone: "MyString"
    ))
  end

  it "renders new admin_icm_modifier_info_personelle form" do
    render

    assert_select "form[action=?][method=?]", admin_icm_modifier_info_personelles_path, "post" do

      assert_select "input[name=?]", "admin_icm_modifier_info_personelle[prenom]"

      assert_select "input[name=?]", "admin_icm_modifier_info_personelle[nom]"

      assert_select "input[name=?]", "admin_icm_modifier_info_personelle[telephone]"
    end
  end
end
