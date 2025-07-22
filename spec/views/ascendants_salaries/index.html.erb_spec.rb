require 'rails_helper'

RSpec.describe "ascendants_salaries/index", type: :view do
  before(:each) do
    assign(:ascendants_salaries, [
      AscendantsSalarie.create!(),
      AscendantsSalarie.create!()
    ])
  end

  it "renders a list of ascendants_salaries" do
    render
  end
end
