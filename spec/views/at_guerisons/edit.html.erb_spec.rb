require 'rails_helper'

RSpec.describe "at_guerisons/edit", type: :view do
  before(:each) do
    @at_guerison = assign(:at_guerison, AtGuerison.create!(
      works_state: "MyString",
      observation: "MyText",
      soumis_par_id: 1
    ))
  end

  it "renders the edit at_guerison form" do
    render

    assert_select "form[action=?][method=?]", at_guerison_path(@at_guerison), "post" do

      assert_select "input[name=?]", "at_guerison[works_state]"

      assert_select "textarea[name=?]", "at_guerison[observation]"

      assert_select "input[name=?]", "at_guerison[soumis_par_id]"
    end
  end
end
