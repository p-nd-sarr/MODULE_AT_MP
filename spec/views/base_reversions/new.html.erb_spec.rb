require 'rails_helper'

RSpec.describe "base_reversions/new", type: :view do
  before(:each) do
    assign(:base_reversion, BaseReversion.new(
      numero_allocataire: "MyString",
      commentaire: "MyText"
    ))
  end

  it "renders new base_reversion form" do
    render

    assert_select "form[action=?][method=?]", base_reversions_path, "post" do

      assert_select "input[name=?]", "base_reversion[numero_allocataire]"

      assert_select "textarea[name=?]", "base_reversion[commentaire]"
    end
  end
end
