require 'rails_helper'

RSpec.describe "demande_remboursement_cotisations/index", type: :view do
  before(:each) do
    assign(:demande_remboursement_cotisations, [
      DemandeRemboursementCotisation.create!(),
      DemandeRemboursementCotisation.create!()
    ])
  end

  it "renders a list of demande_remboursement_cotisations" do
    render
  end
end
