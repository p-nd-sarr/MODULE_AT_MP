require 'rails_helper'

RSpec.describe "admin/quartiers/edit", type: :view do
  before(:each) do
    @admin_quartier = assign(:admin_quartier, Admin::Quartier.create!(
      admin_commune: nil,
      code: 1,
      designation: "MyString"
    ))
  end

  it "renders the edit admin_quartier form" do
    render

    assert_select "form[action=?][method=?]", admin_quartier_path(@admin_quartier), "post" do

      assert_select "input[name=?]", "admin_quartier[admin_commune_id]"

      assert_select "input[name=?]", "admin_quartier[code]"

      assert_select "input[name=?]", "admin_quartier[designation]"
    end
  end
end
