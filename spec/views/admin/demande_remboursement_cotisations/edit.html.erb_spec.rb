require 'rails_helper'

RSpec.describe "admin/demande_remboursement_cotisations/edit", type: :view do
  before(:each) do
    @admin_demande_remboursement_cotisation = assign(:admin_demande_remboursement_cotisation, Admin::DemandeRemboursementCotisation.create!())
  end

  it "renders the edit admin_demande_remboursement_cotisation form" do
    render

    assert_select "form[action=?][method=?]", admin_demande_remboursement_cotisation_path(@admin_demande_remboursement_cotisation), "post" do
    end
  end
end
