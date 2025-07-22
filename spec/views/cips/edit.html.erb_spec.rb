require 'rails_helper'

RSpec.describe "cips/edit", type: :view do
  before(:each) do
    @cip = assign(:cip, Cip.create!())
  end

  it "renders the edit cip form" do
    render

    assert_select "form[action=?][method=?]", cip_path(@cip), "post" do
    end
  end
end
