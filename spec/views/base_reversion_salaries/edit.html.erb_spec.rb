require 'rails_helper'

RSpec.describe "base_reversion_salaries/edit", type: :view do
  before(:each) do
    @base_reversion_salary = assign(:base_reversion_salary, BaseReversionSalary.create!())
  end

  it "renders the edit base_reversion_salary form" do
    render

    assert_select "form[action=?][method=?]", base_reversion_salary_path(@base_reversion_salary), "post" do
    end
  end
end
