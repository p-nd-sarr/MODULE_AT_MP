require 'rails_helper'

RSpec.describe "admin/communes/new", type: :view do
  before(:each) do
    assign(:admin_commune, Admin::Commune.new(
      admin_ville: nil,
      code: 1,
      designation: "MyString"
    ))
  end

  it "renders new admin_commune form" do
    render

    assert_select "form[action=?][method=?]", admin_communes_path, "post" do

      assert_select "input[name=?]", "admin_commune[admin_ville_id]"

      assert_select "input[name=?]", "admin_commune[code]"

      assert_select "input[name=?]", "admin_commune[designation]"
    end
  end
end
