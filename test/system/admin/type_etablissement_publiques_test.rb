require "application_system_test_case"

class Admin::TypeEtablissementPubliquesTest < ApplicationSystemTestCase
  setup do
    @admin_type_etablissement_publique = admin_type_etablissement_publiques(:one)
  end

  test "visiting the index" do
    visit admin_type_etablissement_publiques_url
    assert_selector "h1", text: "Admin/Type Etablissement Publiques"
  end

  test "creating a Type etablissement publique" do
    visit admin_type_etablissement_publiques_url
    click_on "New Admin/Type Etablissement Publique"

    fill_in "Code", with: @admin_type_etablissement_publique.code
    fill_in "Description", with: @admin_type_etablissement_publique.description
    click_on "Create Type etablissement publique"

    assert_text "Type etablissement publique was successfully created"
    click_on "Back"
  end

  test "updating a Type etablissement publique" do
    visit admin_type_etablissement_publiques_url
    click_on "Edit", match: :first

    fill_in "Code", with: @admin_type_etablissement_publique.code
    fill_in "Description", with: @admin_type_etablissement_publique.description
    click_on "Update Type etablissement publique"

    assert_text "Type etablissement publique was successfully updated"
    click_on "Back"
  end

  test "destroying a Type etablissement publique" do
    visit admin_type_etablissement_publiques_url
    page.accept_confirm do
      click_on "Destroy", match: :first
    end

    assert_text "Type etablissement publique was successfully destroyed"
  end
end
