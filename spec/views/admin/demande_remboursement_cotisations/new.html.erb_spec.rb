require 'rails_helper'

RSpec.describe "admin/demande_remboursement_cotisations/new", type: :view do
  before(:each) do
    assign(:admin_demande_remboursement_cotisation, Admin::DemandeRemboursementCotisation.new())
  end

  it "renders new admin_demande_remboursement_cotisation form" do
    render

    assert_select "form[action=?][method=?]", admin_demande_remboursement_cotisations_path, "post" do
    end
  end
end
