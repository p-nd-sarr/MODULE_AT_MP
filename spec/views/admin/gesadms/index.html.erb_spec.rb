require 'rails_helper'

RSpec.describe "admin/gesadms/index", type: :view do
  before(:each) do
    assign(:admin_gesadms, [
      Admin::Gesadm.create!(
        matricule: "Matricule",
        prenom: "Prenom",
        nom: "Nom",
        lieu_naissance: "Lieu Naissance"
      ),
      Admin::Gesadm.create!(
        matricule: "Matricule",
        prenom: "Prenom",
        nom: "Nom",
        lieu_naissance: "Lieu Naissance"
      )
    ])
  end

  it "renders a list of admin/gesadms" do
    render
    assert_select "tr>td", text: "Matricule".to_s, count: 2
    assert_select "tr>td", text: "Prenom".to_s, count: 2
    assert_select "tr>td", text: "Nom".to_s, count: 2
    assert_select "tr>td", text: "Lieu Naissance".to_s, count: 2
  end
end
