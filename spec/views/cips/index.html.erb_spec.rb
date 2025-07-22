require 'rails_helper'

RSpec.describe "cips/index", type: :view do
  before(:each) do
    assign(:cips, [
      Cip.create!(),
      Cip.create!()
    ])
  end

  it "renders a list of cips" do
    render
  end
end
