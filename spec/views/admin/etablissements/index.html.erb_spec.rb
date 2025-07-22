require 'rails_helper'

RSpec.describe "admin/etablissements/index", type: :view do
  before(:each) do
    assign(:admin_etablissements, [
      Admin::Etablissement.create!(),
      Admin::Etablissement.create!()
    ])
  end

  it "renders a list of admin/etablissements" do
    render
  end
end
