require 'rails_helper'

RSpec.describe "admin/salaire_annuels/new", type: :view do
  before(:each) do
    assign(:admin_salaire_annuel, Admin::SalaireAnnuel.new(
      coefficient: 1,
      plancher: 1.5,
      plafond: 1.5
    ))
  end

  it "renders new admin_salaire_annuel form" do
    render

    assert_select "form[action=?][method=?]", admin_salaire_annuels_path, "post" do

      assert_select "input[name=?]", "admin_salaire_annuel[coefficient]"

      assert_select "input[name=?]", "admin_salaire_annuel[plancher]"

      assert_select "input[name=?]", "admin_salaire_annuel[plafond]"
    end
  end
end
