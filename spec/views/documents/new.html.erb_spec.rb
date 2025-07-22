require 'rails_helper'

RSpec.describe "documents/new", type: :view do
  before(:each) do
    assign(:document, Document.new(
      type_document: 1,
      commentaire: "MyText"
    ))
  end

  it "renders new document form" do
    render

    assert_select "form[action=?][method=?]", documents_path, "post" do

      assert_select "input[name=?]", "document[type_document]"

      assert_select "textarea[name=?]", "document[commentaire]"
    end
  end
end
