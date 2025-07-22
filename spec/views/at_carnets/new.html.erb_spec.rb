require 'rails_helper'

RSpec.describe "at_carnets/new", type: :view do
  before(:each) do
    assign(:at_carnet, AtCarnet.new(
      numero_carnet: "MyString",
      arret_travail_id: 1,
      numero_employeur: "MyString"
    ))
  end

  it "renders new at_carnet form" do
    render

    assert_select "form[action=?][method=?]", at_carnets_path, "post" do

      assert_select "input[name=?]", "at_carnet[numero_carnet]"

      assert_select "input[name=?]", "at_carnet[arret_travail_id]"

      assert_select "input[name=?]", "at_carnet[numero_employeur]"
    end
  end
end
