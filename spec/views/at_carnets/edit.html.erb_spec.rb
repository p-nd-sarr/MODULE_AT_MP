require 'rails_helper'

RSpec.describe "at_carnets/edit", type: :view do
  before(:each) do
    @at_carnet = assign(:at_carnet, AtCarnet.create!(
      numero_carnet: "MyString",
      arret_travail_id: 1,
      numero_employeur: "MyString"
    ))
  end

  it "renders the edit at_carnet form" do
    render

    assert_select "form[action=?][method=?]", at_carnet_path(@at_carnet), "post" do

      assert_select "input[name=?]", "at_carnet[numero_carnet]"

      assert_select "input[name=?]", "at_carnet[arret_travail_id]"

      assert_select "input[name=?]", "at_carnet[numero_employeur]"
    end
  end
end
