require 'rails_helper'

RSpec.describe "admin/salaire_annuels/index", type: :view do
  before(:each) do
    assign(:admin_salaire_annuels, [
      Admin::SalaireAnnuel.create!(
        coefficient: 2,
        plancher: 3.5,
        plafond: 4.5
      ),
      Admin::SalaireAnnuel.create!(
        coefficient: 2,
        plancher: 3.5,
        plafond: 4.5
      )
    ])
  end

  it "renders a list of admin/salaire_annuels" do
    render
    assert_select "tr>td", text: 2.to_s, count: 2
    assert_select "tr>td", text: 3.5.to_s, count: 2
    assert_select "tr>td", text: 4.5.to_s, count: 2
  end
end
