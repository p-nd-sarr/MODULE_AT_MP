require 'rails_helper'

RSpec.describe "declaration_divorce_ou_deces_conjoints/edit", type: :view do
  before(:each) do
    @declaration_divorce_ou_deces_conjoint = assign(:declaration_divorce_ou_deces_conjoint, DeclarationDivorceOuDecesConjoint.create!())
  end

  it "renders the edit declaration_divorce_ou_deces_conjoint form" do
    render

    assert_select "form[action=?][method=?]", declaration_divorce_ou_deces_conjoint_path(@declaration_divorce_ou_deces_conjoint), "post" do
    end
  end
end
