require 'rails_helper'

RSpec.describe "admin/association_allocataires/index", type: :view do
  before(:each) do
    assign(:admin_association_allocataires, [
      Admin::AssociationAllocataire.create!(
        name: "Name"
      ),
      Admin::AssociationAllocataire.create!(
        name: "Name"
      )
    ])
  end

  it "renders a list of admin/association_allocataires" do
    render
    assert_select "tr>td", text: "Name".to_s, count: 2
  end
end
