require 'rails_helper'

RSpec.describe "admin/etablissements/edit", type: :view do
  before(:each) do
    @admin_etablissement = assign(:admin_etablissement, Admin::Etablissement.create!())
  end

  it "renders the edit admin_etablissement form" do
    render

    assert_select "form[action=?][method=?]", admin_etablissement_path(@admin_etablissement), "post" do
    end
  end
end
