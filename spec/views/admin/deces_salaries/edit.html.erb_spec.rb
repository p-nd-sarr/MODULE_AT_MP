require 'rails_helper'

RSpec.describe "admin/deces_salaries/edit", type: :view do
  before(:each) do
    @admin_deces_salarie = assign(:admin_deces_salarie, Admin::DecesSalarie.create!(
      numero_affiliation: "MyString",
      prenom: "MyString",
      nom: "MyString",
      numero_piece: "MyString"
    ))
  end

  it "renders the edit admin_deces_salarie form" do
    render

    assert_select "form[action=?][method=?]", admin_deces_salarie_path(@admin_deces_salarie), "post" do

      assert_select "input[name=?]", "admin_deces_salarie[numero_affiliation]"

      assert_select "input[name=?]", "admin_deces_salarie[prenom]"

      assert_select "input[name=?]", "admin_deces_salarie[nom]"

      assert_select "input[name=?]", "admin_deces_salarie[numero_piece]"
    end
  end
end
