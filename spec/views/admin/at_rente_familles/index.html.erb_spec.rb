require 'rails_helper'

RSpec.describe "admin/at_rente_familles/index", type: :view do
  before(:each) do
    assign(:admin_at_rente_familles, [
      Admin::AtRenteFamille.create!(),
      Admin::AtRenteFamille.create!()
    ])
  end

  it "renders a list of admin/at_rente_familles" do
    render
  end
end
