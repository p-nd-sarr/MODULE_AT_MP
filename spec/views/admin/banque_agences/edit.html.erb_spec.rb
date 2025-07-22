require 'rails_helper'

RSpec.describe "admin/banque_agences/edit", type: :view do
  before(:each) do
    @admin_banque_agence = assign(:admin_banque_agence, Admin::BanqueAgence.create!(
      admin_banque: nil,
      nom: "MyString",
      code: "MyString",
      bank_branch_id: "MyString"
    ))
  end

  it "renders the edit admin_banque_agence form" do
    render

    assert_select "form[action=?][method=?]", admin_banque_agence_path(@admin_banque_agence), "post" do

      assert_select "input[name=?]", "admin_banque_agence[admin_banque_id]"

      assert_select "input[name=?]", "admin_banque_agence[nom]"

      assert_select "input[name=?]", "admin_banque_agence[code]"

      assert_select "input[name=?]", "admin_banque_agence[bank_branch_id]"
    end
  end
end
