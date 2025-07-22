require 'rails_helper'

RSpec.describe "base_reversions/index", type: :view do
  before(:each) do
    assign(:base_reversions, [
      BaseReversion.create!(
        numero_allocataire: "Numero Allocataire",
        commentaire: "MyText"
      ),
      BaseReversion.create!(
        numero_allocataire: "Numero Allocataire",
        commentaire: "MyText"
      )
    ])
  end

  it "renders a list of base_reversions" do
    render
    assert_select "tr>td", text: "Numero Allocataire".to_s, count: 2
    assert_select "tr>td", text: "MyText".to_s, count: 2
  end
end
