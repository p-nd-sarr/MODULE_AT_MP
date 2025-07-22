require 'rails_helper'

RSpec.describe "declaration_divorce_ou_deces_conjoints/new", type: :view do
  before(:each) do
    assign(:declaration_divorce_ou_deces_conjoint, DeclarationDivorceOuDecesConjoint.new())
  end

  it "renders new declaration_divorce_ou_deces_conjoint form" do
    render

    assert_select "form[action=?][method=?]", declaration_divorce_ou_deces_conjoints_path, "post" do
    end
  end
end
