require 'rails_helper'

RSpec.describe "admin/compta_nature_prestations/edit", type: :view do
  before(:each) do
    @admin_compta_nature_prestation = assign(:admin_compta_nature_prestation, Admin::ComptaNaturePrestation.create!(
      code: "MyString",
      libelle: "MyString",
      entite: 1,
      branche: 1
    ))
  end

  it "renders the edit admin_compta_nature_prestation form" do
    render

    assert_select "form[action=?][method=?]", admin_compta_nature_prestation_path(@admin_compta_nature_prestation), "post" do

      assert_select "input[name=?]", "admin_compta_nature_prestation[code]"

      assert_select "input[name=?]", "admin_compta_nature_prestation[libelle]"

      assert_select "input[name=?]", "admin_compta_nature_prestation[entite]"

      assert_select "input[name=?]", "admin_compta_nature_prestation[branche]"
    end
  end
end
