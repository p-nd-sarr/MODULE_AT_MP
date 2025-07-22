require 'rails_helper'

RSpec.describe "admin/regions/new", type: :view do
  before(:each) do
    assign(:admin_region, Admin::Region.new(
      designation: "MyString",
      code: 1,
      pays: "MyString"
    ))
  end

  it "renders new admin_region form" do
    render

    assert_select "form[action=?][method=?]", admin_regions_path, "post" do

      assert_select "input[name=?]", "admin_region[designation]"

      assert_select "input[name=?]", "admin_region[code]"

      assert_select "input[name=?]", "admin_region[pays]"
    end
  end
end
