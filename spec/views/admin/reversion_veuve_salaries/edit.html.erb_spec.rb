require 'rails_helper'

RSpec.describe "admin/reversion_veuve_salaries/edit", type: :view do
  before(:each) do
    @admin_reversion_veuve_salarie = assign(:admin_reversion_veuve_salarie, Admin::ReversionVeuveSalarie.create!())
  end

  it "renders the edit admin_reversion_veuve_salarie form" do
    render

    assert_select "form[action=?][method=?]", admin_reversion_veuve_salarie_path(@admin_reversion_veuve_salarie), "post" do
    end
  end
end
