require 'rails_helper'

RSpec.describe "admin/salaire_annuels/show", type: :view do
  before(:each) do
    @admin_salaire_annuel = assign(:admin_salaire_annuel, Admin::SalaireAnnuel.create!(
      coefficient: 2,
      plancher: 3.5,
      plafond: 4.5
    ))
  end

  it "renders attributes in <p>" do
    render
    expect(rendered).to match(/2/)
    expect(rendered).to match(/3.5/)
    expect(rendered).to match(/4.5/)
  end
end
