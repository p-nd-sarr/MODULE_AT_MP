require 'rails_helper'

RSpec.describe "ascendants_salaries/show", type: :view do
  before(:each) do
    @ascendants_salarie = assign(:ascendants_salarie, AscendantsSalarie.create!())
  end

  it "renders attributes in <p>" do
    render
  end
end
