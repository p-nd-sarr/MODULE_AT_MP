require 'rails_helper'

RSpec.describe "admin/departements/edit", type: :view do
  before(:each) do
    @admin_departement = assign(:admin_departement, Admin::Departement.create!(
      region: nil,
      designation: "MyString",
      code: 1
    ))
  end

  it "renders the edit admin_departement form" do
    render

    assert_select "form[action=?][method=?]", admin_departement_path(@admin_departement), "post" do

      assert_select "input[name=?]", "admin_departement[region_id]"

      assert_select "input[name=?]", "admin_departement[designation]"

      assert_select "input[name=?]", "admin_departement[code]"
    end
  end
end
