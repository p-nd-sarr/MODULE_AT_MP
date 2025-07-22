require 'rails_helper'

RSpec.describe "demande_remboursement_cotisations/show", type: :view do
  before(:each) do
    @demande_remboursement_cotisation = assign(:demande_remboursement_cotisation, DemandeRemboursementCotisation.create!())
  end

  it "renders attributes in <p>" do
    render
  end
end
