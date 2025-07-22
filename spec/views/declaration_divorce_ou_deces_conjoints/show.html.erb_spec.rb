require 'rails_helper'

RSpec.describe "declaration_divorce_ou_deces_conjoints/show", type: :view do
  before(:each) do
    @declaration_divorce_ou_deces_conjoint = assign(:declaration_divorce_ou_deces_conjoint, DeclarationDivorceOuDecesConjoint.create!())
  end

  it "renders attributes in <p>" do
    render
  end
end
