require 'rails_helper'

RSpec.describe "base_reversions/show", type: :view do
  before(:each) do
    @base_reversion = assign(:base_reversion, BaseReversion.create!(
      numero_allocataire: "Numero Allocataire",
      commentaire: "MyText"
    ))
  end

  it "renders attributes in <p>" do
    render
    expect(rendered).to match(/Numero Allocataire/)
    expect(rendered).to match(/MyText/)
  end
end
