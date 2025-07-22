require 'rails_helper'

RSpec.describe "base_reversion_salaries/index", type: :view do
  before(:each) do
    assign(:base_reversion_salaries, [
      BaseReversionSalarie.create!(),
      BaseReversionSalarie.create!()
    ])
  end

  it "renders a list of base_reversion_salaries" do
    render
  end
end
