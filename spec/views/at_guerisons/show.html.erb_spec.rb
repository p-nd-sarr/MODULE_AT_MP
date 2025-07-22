require 'rails_helper'

RSpec.describe "at_guerisons/show", type: :view do
  before(:each) do
    @at_guerison = assign(:at_guerison, AtGuerison.create!(
      works_state: "Works State",
      observation: "MyText",
      soumis_par_id: 2
    ))
  end

  it "renders attributes in <p>" do
    render
    expect(rendered).to match(/Works State/)
    expect(rendered).to match(/MyText/)
    expect(rendered).to match(/2/)
  end
end
