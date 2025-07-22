require 'rails_helper'

RSpec.describe "base_reversion_salaries/show", type: :view do
  before(:each) do
    @base_reversion_salarie = assign(:base_reversion_salarie, BaseReversionSalarie.create!())
  end

  it "renders attributes in <p>" do
    render
  end
end
