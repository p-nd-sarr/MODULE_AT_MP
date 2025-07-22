require 'rails_helper'

RSpec.describe "admin/gesadms/new", type: :view do
  before(:each) do
    assign(:admin_gesadm, Admin::Gesadm.new(
      matricule: "MyString",
      prenom: "MyString",
      nom: "MyString",
      lieu_naissance: "MyString"
    ))
  end

  it "renders new admin_gesadm form" do
    render

    assert_select "form[action=?][method=?]", admin_gesadms_path, "post" do

      assert_select "input[name=?]", "admin_gesadm[matricule]"

      assert_select "input[name=?]", "admin_gesadm[prenom]"

      assert_select "input[name=?]", "admin_gesadm[nom]"

      assert_select "input[name=?]", "admin_gesadm[lieu_naissance]"
    end
  end
end
