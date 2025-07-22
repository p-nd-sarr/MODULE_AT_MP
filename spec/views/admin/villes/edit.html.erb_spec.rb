require 'rails_helper'

RSpec.describe "admin/villes/edit", type: :view do
  before(:each) do
    @admin_ville = assign(:admin_ville, Admin::Ville.create!(
      admin_departement: nil,
      code: 1,
      designation: "MyString"
    ))
  end

  it "renders the edit admin_ville form" do
    render

    assert_select "form[action=?][method=?]", admin_ville_path(@admin_ville), "post" do

      assert_select "input[name=?]", "admin_ville[admin_departement_id]"

      assert_select "input[name=?]", "admin_ville[code]"

      assert_select "input[name=?]", "admin_ville[designation]"
    end
  end
end
