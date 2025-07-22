require 'rails_helper'

RSpec.describe "admin/gesadms/show", type: :view do
  before(:each) do
    @admin_gesadm = assign(:admin_gesadm, Admin::Gesadm.create!(
      matricule: "Matricule",
      prenom: "Prenom",
      nom: "Nom",
      lieu_naissance: "Lieu Naissance"
    ))
  end

  it "renders attributes in <p>" do
    render
    expect(rendered).to match(/Matricule/)
    expect(rendered).to match(/Prenom/)
    expect(rendered).to match(/Nom/)
    expect(rendered).to match(/Lieu Naissance/)
  end
end
