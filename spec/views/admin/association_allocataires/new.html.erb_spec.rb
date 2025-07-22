require 'rails_helper'

RSpec.describe "admin/association_allocataires/new", type: :view do
  before(:each) do
    assign(:admin_association_allocataire, Admin::AssociationAllocataire.new(
      name: "MyString"
    ))
  end

  it "renders new admin_association_allocataire form" do
    render

    assert_select "form[action=?][method=?]", admin_association_allocataires_path, "post" do

      assert_select "input[name=?]", "admin_association_allocataire[name]"
    end
  end
end
