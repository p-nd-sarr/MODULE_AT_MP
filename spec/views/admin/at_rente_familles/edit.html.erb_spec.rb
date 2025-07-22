require 'rails_helper'

RSpec.describe "admin/at_rente_familles/edit", type: :view do
  before(:each) do
    @admin_at_rente_famille = assign(:admin_at_rente_famille, Admin::AtRenteFamille.create!())
  end

  it "renders the edit admin_at_rente_famille form" do
    render

    assert_select "form[action=?][method=?]", admin_at_rente_famille_path(@admin_at_rente_famille), "post" do
    end
  end
end
