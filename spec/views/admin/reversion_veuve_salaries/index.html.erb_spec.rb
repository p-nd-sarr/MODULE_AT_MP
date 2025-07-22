require 'rails_helper'

RSpec.describe "admin/reversion_veuve_salaries/index", type: :view do
  before(:each) do
    assign(:admin_reversion_veuve_salaries, [
      Admin::ReversionVeuveSalarie.create!(),
      Admin::ReversionVeuveSalarie.create!()
    ])
  end

  it "renders a list of admin/reversion_veuve_salaries" do
    render
  end
end
