require 'rails_helper'

RSpec.describe "admin/reversion_veuve_salaries/new", type: :view do
  before(:each) do
    assign(:admin_reversion_veuve_salarie, Admin::ReversionVeuveSalarie.new())
  end

  it "renders new admin_reversion_veuve_salarie form" do
    render

    assert_select "form[action=?][method=?]", admin_reversion_veuve_salaries_path, "post" do
    end
  end
end
