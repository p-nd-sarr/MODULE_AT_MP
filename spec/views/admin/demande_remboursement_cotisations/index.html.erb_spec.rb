require 'rails_helper'

RSpec.describe "admin/demande_remboursement_cotisations/index", type: :view do
  before(:each) do
    assign(:admin_demande_remboursement_cotisations, [
      Admin::DemandeRemboursementCotisation.create!(),
      Admin::DemandeRemboursementCotisation.create!()
    ])
  end

  it "renders a list of admin/demande_remboursement_cotisations" do
    render
  end
end
