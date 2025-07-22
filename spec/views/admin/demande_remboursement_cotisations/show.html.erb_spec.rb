require 'rails_helper'

RSpec.describe "admin/demande_remboursement_cotisations/show", type: :view do
  before(:each) do
    @admin_demande_remboursement_cotisation = assign(:admin_demande_remboursement_cotisation, Admin::DemandeRemboursementCotisation.create!())
  end

  it "renders attributes in <p>" do
    render
  end
end
