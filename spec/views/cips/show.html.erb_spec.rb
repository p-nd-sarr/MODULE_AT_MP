require 'rails_helper'

RSpec.describe "cips/show", type: :view do
  before(:each) do
    @cip = assign(:cip, Cip.create!())
  end

  it "renders attributes in <p>" do
    render
  end
end
