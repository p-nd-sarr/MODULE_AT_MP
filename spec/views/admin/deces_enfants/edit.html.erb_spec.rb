require 'rails_helper'

RSpec.describe "admin/deces_enfants/edit", type: :view do
  before(:each) do
    @admin_deces_enfant = assign(:admin_deces_enfant, Admin::DecesEnfant.create!(
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

  it "renders the edit admin_deces_enfant form" do
    render

    assert_select "form[action=?][method=?]", admin_deces_enfant_path(@admin_deces_enfant), "post" do

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
