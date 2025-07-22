require 'rails_helper'

RSpec.describe "demande_remboursement_cotisations/edit", type: :view do
  before(:each) do
    @demande_remboursement_cotisation = assign(:demande_remboursement_cotisation, DemandeRemboursementCotisation.create!())
  end

  it "renders the edit demande_remboursement_cotisation form" do
    render

    assert_select "form[action=?][method=?]", demande_remboursement_cotisation_path(@demande_remboursement_cotisation), "post" do
    end
  end
end
