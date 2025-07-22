require 'rails_helper'

RSpec.describe "admin/compta_nature_prestations/new", type: :view do
  before(:each) do
    assign(:admin_compta_nature_prestation, Admin::ComptaNaturePrestation.new(
      code: "MyString",
      libelle: "MyString",
      entite: 1,
      branche: 1
    ))
  end

  it "renders new admin_compta_nature_prestation form" do
    render

    assert_select "form[action=?][method=?]", admin_compta_nature_prestations_path, "post" do

      assert_select "input[name=?]", "admin_compta_nature_prestation[code]"

      assert_select "input[name=?]", "admin_compta_nature_prestation[libelle]"

      assert_select "input[name=?]", "admin_compta_nature_prestation[entite]"

      assert_select "input[name=?]", "admin_compta_nature_prestation[branche]"
    end
  end
end
