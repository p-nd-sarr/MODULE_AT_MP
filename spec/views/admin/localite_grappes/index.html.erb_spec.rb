require 'rails_helper'

RSpec.describe "admin/localite_grappes/index", type: :view do
  before(:each) do
    assign(:admin_localite_grappes, [
      Admin::LocaliteGrappe.create!(
        code_pays: 2,
        code_localite: 3,
        localite: "Localite"
      ),
      Admin::LocaliteGrappe.create!(
        code_pays: 2,
        code_localite: 3,
        localite: "Localite"
      )
    ])
  end

  it "renders a list of admin/localite_grappes" do
    render
    assert_select "tr>td", text: 2.to_s, count: 2
    assert_select "tr>td", text: 3.to_s, count: 2
    assert_select "tr>td", text: "Localite".to_s, count: 2
  end
end
