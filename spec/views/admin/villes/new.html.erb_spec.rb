require 'rails_helper'

RSpec.describe "admin/villes/new", type: :view do
  before(:each) do
    assign(:admin_ville, Admin::Ville.new(
      admin_departement: nil,
      code: 1,
      designation: "MyString"
    ))
  end

  it "renders new admin_ville form" do
    render

    assert_select "form[action=?][method=?]", admin_villes_path, "post" do

      assert_select "input[name=?]", "admin_ville[admin_departement_id]"

      assert_select "input[name=?]", "admin_ville[code]"

      assert_select "input[name=?]", "admin_ville[designation]"
    end
  end
end
