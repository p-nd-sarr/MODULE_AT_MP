require 'rails_helper'

RSpec.describe "admin/gesadms/edit", type: :view do
  before(:each) do
    @admin_gesadm = assign(:admin_gesadm, Admin::Gesadm.create!(
      matricule: "MyString",
      prenom: "MyString",
      nom: "MyString",
      lieu_naissance: "MyString"
    ))
  end

  it "renders the edit admin_gesadm form" do
    render

    assert_select "form[action=?][method=?]", admin_gesadm_path(@admin_gesadm), "post" do

      assert_select "input[name=?]", "admin_gesadm[matricule]"

      assert_select "input[name=?]", "admin_gesadm[prenom]"

      assert_select "input[name=?]", "admin_gesadm[nom]"

      assert_select "input[name=?]", "admin_gesadm[lieu_naissance]"
    end
  end
end
