require 'rails_helper'

RSpec.describe "admin/etablissements/new", type: :view do
  before(:each) do
    assign(:admin_etablissement, Admin::Etablissement.new())
  end

  it "renders new admin_etablissement form" do
    render

    assert_select "form[action=?][method=?]", admin_etablissements_path, "post" do
    end
  end
end
