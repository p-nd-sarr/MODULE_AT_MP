require 'rails_helper'

RSpec.describe "admin/rentes/index", type: :view do
  before(:each) do
    assign(:admin_rentes, [
      Admin::Rente.create!(),
      Admin::Rente.create!()
    ])
  end

  it "renders a list of admin/rentes" do
    render
  end
end
