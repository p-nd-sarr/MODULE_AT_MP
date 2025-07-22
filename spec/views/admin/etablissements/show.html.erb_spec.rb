require 'rails_helper'

RSpec.describe "admin/etablissements/show", type: :view do
  before(:each) do
    @admin_etablissement = assign(:admin_etablissement, Admin::Etablissement.create!())
  end

  it "renders attributes in <p>" do
    render
  end
end
