require 'rails_helper'

RSpec.describe "admin/at_rente_familles/show", type: :view do
  before(:each) do
    @admin_at_rente_famille = assign(:admin_at_rente_famille, Admin::AtRenteFamille.create!())
  end

  it "renders attributes in <p>" do
    render
  end
end
