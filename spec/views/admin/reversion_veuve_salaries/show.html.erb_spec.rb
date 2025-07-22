require 'rails_helper'

RSpec.describe "admin/reversion_veuve_salaries/show", type: :view do
  before(:each) do
    @admin_reversion_veuve_salarie = assign(:admin_reversion_veuve_salarie, Admin::ReversionVeuveSalarie.create!())
  end

  it "renders attributes in <p>" do
    render
  end
end
