require 'rails_helper'

RSpec.describe "at_guerisons/new", type: :view do
  before(:each) do
    assign(:at_guerison, AtGuerison.new(
      works_state: "MyString",
      observation: "MyText",
      soumis_par_id: 1
    ))
  end

  it "renders new at_guerison form" do
    render

    assert_select "form[action=?][method=?]", at_guerisons_path, "post" do

      assert_select "input[name=?]", "at_guerison[works_state]"

      assert_select "textarea[name=?]", "at_guerison[observation]"

      assert_select "input[name=?]", "at_guerison[soumis_par_id]"
    end
  end
end
