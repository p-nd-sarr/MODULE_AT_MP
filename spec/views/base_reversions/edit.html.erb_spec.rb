require 'rails_helper'

RSpec.describe "base_reversions/edit", type: :view do
  before(:each) do
    @base_reversion = assign(:base_reversion, BaseReversion.create!(
      numero_allocataire: "MyString",
      commentaire: "MyText"
    ))
  end

  it "renders the edit base_reversion form" do
    render

    assert_select "form[action=?][method=?]", base_reversion_path(@base_reversion), "post" do

      assert_select "input[name=?]", "base_reversion[numero_allocataire]"

      assert_select "textarea[name=?]", "base_reversion[commentaire]"
    end
  end
end
