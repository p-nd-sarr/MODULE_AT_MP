require 'rails_helper'

RSpec.describe "admin/banque_agences/show", type: :view do
  before(:each) do
    @admin_banque_agence = assign(:admin_banque_agence, Admin::BanqueAgence.create!(
      admin_banque: nil,
      nom: "Nom",
      code: "Code",
      bank_branch_id: "Bank Branch"
    ))
  end

  it "renders attributes in <p>" do
    render
    expect(rendered).to match(//)
    expect(rendered).to match(/Nom/)
    expect(rendered).to match(/Code/)
    expect(rendered).to match(/Bank Branch/)
  end
end
