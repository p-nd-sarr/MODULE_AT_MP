require 'rails_helper'

RSpec.describe "base_reversion_salaries/new", type: :view do
  before(:each) do
    assign(:base_reversion_salarie, BaseReversionSalarie.new())
  end

  it "renders new base_reversion_salarie form" do
    render

    assert_select "form[action=?][method=?]", base_reversion_salaries_path, "post" do
    end
  end
end
