require 'rails_helper'

RSpec.describe "admin/association_allocataires/edit", type: :view do
  before(:each) do
    @admin_association_allocataire = assign(:admin_association_allocataire, Admin::AssociationAllocataire.create!(
      name: "MyString"
    ))
  end

  it "renders the edit admin_association_allocataire form" do
    render

    assert_select "form[action=?][method=?]", admin_association_allocataire_path(@admin_association_allocataire), "post" do

      assert_select "input[name=?]", "admin_association_allocataire[name]"
    end
  end
end
