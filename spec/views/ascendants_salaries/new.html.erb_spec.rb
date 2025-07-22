require 'rails_helper'

RSpec.describe "ascendants_salaries/new", type: :view do
  before(:each) do
    assign(:ascendants_salarie, AscendantsSalarie.new())
  end

  it "renders new ascendants_salarie form" do
    render

    assert_select "form[action=?][method=?]", ascendants_salaries_path, "post" do
    end
  end
end
