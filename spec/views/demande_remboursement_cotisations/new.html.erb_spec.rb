require 'rails_helper'

RSpec.describe "demande_remboursement_cotisations/new", type: :view do
  before(:each) do
    assign(:demande_remboursement_cotisation, DemandeRemboursementCotisation.new())
  end

  it "renders new demande_remboursement_cotisation form" do
    render

    assert_select "form[action=?][method=?]", demande_remboursement_cotisations_path, "post" do
    end
  end
end
