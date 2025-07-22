require 'rails_helper'

RSpec.describe "admin/rentes/edit", type: :view do
  before(:each) do
    @admin_rente = assign(:admin_rente, Admin::Rente.create!())
  end

  it "renders the edit admin_rente form" do
    render

    assert_select "form[action=?][method=?]", admin_rente_path(@admin_rente), "post" do
    end
  end
end
