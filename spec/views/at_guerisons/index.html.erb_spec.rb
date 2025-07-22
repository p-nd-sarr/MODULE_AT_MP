require 'rails_helper'

RSpec.describe "at_guerisons/index", type: :view do
  before(:each) do
    assign(:at_guerisons, [
      AtGuerison.create!(
        works_state: "Works State",
        observation: "MyText",
        soumis_par_id: 2
      ),
      AtGuerison.create!(
        works_state: "Works State",
        observation: "MyText",
        soumis_par_id: 2
      )
    ])
  end

  it "renders a list of at_guerisons" do
    render
    assert_select "tr>td", text: "Works State".to_s, count: 2
    assert_select "tr>td", text: "MyText".to_s, count: 2
    assert_select "tr>td", text: 2.to_s, count: 2
  end
end
