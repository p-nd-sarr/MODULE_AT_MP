require 'rails_helper'

RSpec.describe "reversion_veuves/edit", type: :view do
  before(:each) do
    @reversion_veuve = assign(:reversion_veuve, ReversionVeuve.create!(
      workflow_state: "MyString",
      prenom: "MyString",
      nom: "MyString",
      lieu_naissance: "MyString",
      numero_affiliation: "MyString"
    ))
  end

  it "renders the edit reversion_veuve form" do
    render

    assert_select "form[action=?][method=?]", reversion_veuve_path(@reversion_veuve), "post" do

      assert_select "input[name=?]", "reversion_veuve[workflow_state]"

      assert_select "input[name=?]", "reversion_veuve[prenom]"

      assert_select "input[name=?]", "reversion_veuve[nom]"

      assert_select "input[name=?]", "reversion_veuve[lieu_naissance]"

      assert_select "input[name=?]", "reversion_veuve[numero_affiliation]"
    end
  end
end
