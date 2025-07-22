require 'rails_helper'

RSpec.describe "admin/salaire_annuels/edit", type: :view do
  before(:each) do
    @admin_salaire_annuel = assign(:admin_salaire_annuel, Admin::SalaireAnnuel.create!(
      coefficient: 1,
      plancher: 1.5,
      plafond: 1.5
    ))
  end

  it "renders the edit admin_salaire_annuel form" do
    render

    assert_select "form[action=?][method=?]", admin_salaire_annuel_path(@admin_salaire_annuel), "post" do

      assert_select "input[name=?]", "admin_salaire_annuel[coefficient]"

      assert_select "input[name=?]", "admin_salaire_annuel[plancher]"

      assert_select "input[name=?]", "admin_salaire_annuel[plafond]"
    end
  end
end
