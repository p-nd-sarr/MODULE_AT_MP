require 'rails_helper'

RSpec.describe "documents/edit", type: :view do
  before(:each) do
    @document = assign(:document, Document.create!(
      type_document: 1,
      commentaire: "MyText"
    ))
  end

  it "renders the edit document form" do
    render

    assert_select "form[action=?][method=?]", document_path(@document), "post" do

      assert_select "input[name=?]", "document[type_document]"

      assert_select "textarea[name=?]", "document[commentaire]"
    end
  end
end
