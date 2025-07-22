require 'rails_helper'

RSpec.describe "declaration_divorce_ou_deces_conjoints/index", type: :view do
  before(:each) do
    assign(:declaration_divorce_ou_deces_conjoints, [
      DeclarationDivorceOuDecesConjoint.create!(),
      DeclarationDivorceOuDecesConjoint.create!()
    ])
  end

  it "renders a list of declaration_divorce_ou_deces_conjoints" do
    render
  end
end
