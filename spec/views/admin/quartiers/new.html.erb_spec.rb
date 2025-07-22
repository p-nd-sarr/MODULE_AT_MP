require 'rails_helper'

RSpec.describe "admin/quartiers/new", type: :view do
  before(:each) do
    assign(:admin_quartier, Admin::Quartier.new(
      admin_commune: nil,
      code: 1,
      designation: "MyString"
    ))
  end

  it "renders new admin_quartier form" do
    render

    assert_select "form[action=?][method=?]", admin_quartiers_path, "post" do

      assert_select "input[name=?]", "admin_quartier[admin_commune_id]"

      assert_select "input[name=?]", "admin_quartier[code]"

      assert_select "input[name=?]", "admin_quartier[designation]"
    end
  end
end
