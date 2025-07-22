require 'rails_helper'

RSpec.describe "admin/communes/edit", type: :view do
  before(:each) do
    @admin_commune = assign(:admin_commune, Admin::Commune.create!(
      admin_ville: nil,
      code: 1,
      designation: "MyString"
    ))
  end

  it "renders the edit admin_commune form" do
    render

    assert_select "form[action=?][method=?]", admin_commune_path(@admin_commune), "post" do

      assert_select "input[name=?]", "admin_commune[admin_ville_id]"

      assert_select "input[name=?]", "admin_commune[code]"

      assert_select "input[name=?]", "admin_commune[designation]"
    end
  end
end
