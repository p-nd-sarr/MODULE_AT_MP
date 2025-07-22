require 'rails_helper'

RSpec.describe "cips/new", type: :view do
  before(:each) do
    assign(:cip, Cip.new())
  end

  it "renders new cip form" do
    render

    assert_select "form[action=?][method=?]", cips_path, "post" do
    end
  end
end
