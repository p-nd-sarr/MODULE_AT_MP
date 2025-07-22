require 'rails_helper'

RSpec.describe "admin/at_rente_familles/new", type: :view do
  before(:each) do
    assign(:admin_at_rente_famille, Admin::AtRenteFamille.new())
  end

  it "renders new admin_at_rente_famille form" do
    render

    assert_select "form[action=?][method=?]", admin_at_rente_familles_path, "post" do
    end
  end
end
