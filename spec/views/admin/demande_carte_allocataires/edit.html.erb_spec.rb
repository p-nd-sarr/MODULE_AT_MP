require 'rails_helper'

RSpec.describe "admin/demande_carte_allocataires/edit", type: :view do
  before(:each) do
    @admin_demande_carte_allocataire = assign(:admin_demande_carte_allocataire, Admin::DemandeCarteAllocataire.create!(
      user: nil,
      numero_document: "MyString",
      agence_enregistrement_id: 1,
      nom: "MyString",
      prenom: "MyString",
      nin: "MyString",
      email: "MyString",
      adresse: "MyString",
      agence_retrait_id: 1,
      telephone: "MyString"
    ))
  end

  it "renders the edit admin_demande_carte_allocataire form" do
    render

    assert_select "form[action=?][method=?]", admin_demande_carte_allocataire_path(@admin_demande_carte_allocataire), "post" do

      assert_select "input[name=?]", "admin_demande_carte_allocataire[user_id]"

      assert_select "input[name=?]", "admin_demande_carte_allocataire[numero_document]"

      assert_select "input[name=?]", "admin_demande_carte_allocataire[agence_enregistrement_id]"

      assert_select "input[name=?]", "admin_demande_carte_allocataire[nom]"

      assert_select "input[name=?]", "admin_demande_carte_allocataire[prenom]"

      assert_select "input[name=?]", "admin_demande_carte_allocataire[nin]"

      assert_select "input[name=?]", "admin_demande_carte_allocataire[email]"

      assert_select "input[name=?]", "admin_demande_carte_allocataire[adresse]"

      assert_select "input[name=?]", "admin_demande_carte_allocataire[agence_retrait_id]"

      assert_select "input[name=?]", "admin_demande_carte_allocataire[telephone]"
    end
  end
end
