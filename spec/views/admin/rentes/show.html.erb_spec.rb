require 'rails_helper'

RSpec.describe "admin/rentes/show", type: :view do
  before(:each) do
    @admin_rente = assign(:admin_rente, Admin::Rente.create!())
  end

  it "renders attributes in <p>" do
    render
  end
end
