require 'rails_helper'

RSpec.describe "admin/localite_grappes/edit", type: :view do
  before(:each) do
    @admin_localite_grappe = assign(:admin_localite_grappe, Admin::LocaliteGrappe.create!(
      code_pays: 1,
      code_localite: 1,
      localite: "MyString"
    ))
  end

  it "renders the edit admin_localite_grappe form" do
    render

    assert_select "form[action=?][method=?]", admin_localite_grappe_path(@admin_localite_grappe), "post" do

      assert_select "input[name=?]", "admin_localite_grappe[code_pays]"

      assert_select "input[name=?]", "admin_localite_grappe[code_localite]"

      assert_select "input[name=?]", "admin_localite_grappe[localite]"
    end
  end
end
