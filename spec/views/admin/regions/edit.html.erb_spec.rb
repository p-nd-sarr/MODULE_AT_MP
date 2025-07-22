require 'rails_helper'

RSpec.describe "admin/regions/edit", type: :view do
  before(:each) do
    @admin_region = assign(:admin_region, Admin::Region.create!(
      designation: "MyString",
      code: 1,
      pays: "MyString"
    ))
  end

  it "renders the edit admin_region form" do
    render

    assert_select "form[action=?][method=?]", admin_region_path(@admin_region), "post" do

      assert_select "input[name=?]", "admin_region[designation]"

      assert_select "input[name=?]", "admin_region[code]"

      assert_select "input[name=?]", "admin_region[pays]"
    end
  end
end
