require 'rails_helper'

RSpec.describe "admin/rentes/new", type: :view do
  before(:each) do
    assign(:admin_rente, Admin::Rente.new())
  end

  it "renders new admin_rente form" do
    render

    assert_select "form[action=?][method=?]", admin_rentes_path, "post" do
    end
  end
end
