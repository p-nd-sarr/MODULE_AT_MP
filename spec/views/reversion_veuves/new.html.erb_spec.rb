require 'rails_helper'

RSpec.describe "reversion_veuves/new", type: :view do
  before(:each) do
    assign(:reversion_veuve, ReversionVeuve.new(
      workflow_state: "MyString",
      prenom: "MyString",
      nom: "MyString",
      lieu_naissance: "MyString",
      numero_affiliation: "MyString"
    ))
  end

  it "renders new reversion_veuve form" do
    render

    assert_select "form[action=?][method=?]", reversion_veuves_path, "post" do

      assert_select "input[name=?]", "reversion_veuve[workflow_state]"

      assert_select "input[name=?]", "reversion_veuve[prenom]"

      assert_select "input[name=?]", "reversion_veuve[nom]"

      assert_select "input[name=?]", "reversion_veuve[lieu_naissance]"

      assert_select "input[name=?]", "reversion_veuve[numero_affiliation]"
    end
  end
end
