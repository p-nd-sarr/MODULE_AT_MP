require 'rails_helper'

RSpec.describe "admin/banque_agences/index", type: :view do
  before(:each) do
    assign(:admin_banque_agences, [
      Admin::BanqueAgence.create!(
        admin_banque: nil,
        nom: "Nom",
        code: "Code",
        bank_branch_id: "Bank Branch"
      ),
      Admin::BanqueAgence.create!(
        admin_banque: nil,
        nom: "Nom",
        code: "Code",
        bank_branch_id: "Bank Branch"
      )
    ])
  end

  it "renders a list of admin/banque_agences" do
    render
    assert_select "tr>td", text: nil.to_s, count: 2
    assert_select "tr>td", text: "Nom".to_s, count: 2
    assert_select "tr>td", text: "Code".to_s, count: 2
    assert_select "tr>td", text: "Bank Branch".to_s, count: 2
  end
end
