require 'rails_helper'

RSpec.describe "admin/deces_enfants/new", type: :view do
  before(:each) do
    assign(:admin_deces_enfant, Admin::DecesEnfant.new(
      numero_affiliation: "",
      prenom: "",
      nom: "",
      date_naissance: "",
      date_deces,: "MyString",
      prenom_salarie: "",
      nom_salarie: "",
      type_piece: "",
      numero_piece: "MyString"
    ))
  end

  it "renders new admin_deces_enfant form" do
    render

    assert_select "form[action=?][method=?]", admin_deces_enfants_path, "post" do

      assert_select "input[name=?]", "admin_deces_enfant[numero_affiliation]"

      assert_select "input[name=?]", "admin_deces_enfant[prenom]"

      assert_select "input[name=?]", "admin_deces_enfant[nom]"

      assert_select "input[name=?]", "admin_deces_enfant[date_naissance]"

      assert_select "input[name=?]", "admin_deces_enfant[date_deces,]"

      assert_select "input[name=?]", "admin_deces_enfant[prenom_salarie]"

      assert_select "input[name=?]", "admin_deces_enfant[nom_salarie]"

      assert_select "input[name=?]", "admin_deces_enfant[type_piece]"

      assert_select "input[name=?]", "admin_deces_enfant[numero_piece]"
    end
  end
end
