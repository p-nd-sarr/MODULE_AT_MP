require 'rails_helper'

RSpec.describe "ascendants_salaries/edit", type: :view do
  before(:each) do
    @ascendants_salarie = assign(:ascendants_salarie, AscendantsSalarie.create!())
  end

  it "renders the edit ascendants_salarie form" do
    render

    assert_select "form[action=?][method=?]", ascendants_salarie_path(@ascendants_salarie), "post" do
    end
  end
end
