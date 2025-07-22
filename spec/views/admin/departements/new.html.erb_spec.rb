require 'rails_helper'

RSpec.describe "admin/departements/new", type: :view do
  before(:each) do
    assign(:admin_departement, Admin::Departement.new(
      region: nil,
      designation: "MyString",
      code: 1
    ))
  end

  it "renders new admin_departement form" do
    render

    assert_select "form[action=?][method=?]", admin_departements_path, "post" do

      assert_select "input[name=?]", "admin_departement[region_id]"

      assert_select "input[name=?]", "admin_departement[designation]"

      assert_select "input[name=?]", "admin_departement[code]"
    end
  end
end
