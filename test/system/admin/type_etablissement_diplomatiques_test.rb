require "application_system_test_case"

class Admin::TypeEtablissementDiplomatiquesTest < ApplicationSystemTestCase
  setup do
    @admin_type_etablissement_diplomatique = admin_type_etablissement_diplomatiques(:one)
  end

  test "visiting the index" do
    visit admin_type_etablissement_diplomatiques_url
    assert_selector "h1", text: "Admin/Type Etablissement Diplomatiques"
  end

  test "creating a Type etablissement diplomatique" do
    visit admin_type_etablissement_diplomatiques_url
    click_on "New Admin/Type Etablissement Diplomatique"

    fill_in "Code", with: @admin_type_etablissement_diplomatique.code
    fill_in "Description", with: @admin_type_etablissement_diplomatique.description
    click_on "Create Type etablissement diplomatique"

    assert_text "Type etablissement diplomatique was successfully created"
    click_on "Back"
  end

  test "updating a Type etablissement diplomatique" do
    visit admin_type_etablissement_diplomatiques_url
    click_on "Edit", match: :first

    fill_in "Code", with: @admin_type_etablissement_diplomatique.code
    fill_in "Description", with: @admin_type_etablissement_diplomatique.description
    click_on "Update Type etablissement diplomatique"

    assert_text "Type etablissement diplomatique was successfully updated"
    click_on "Back"
  end

  test "destroying a Type etablissement diplomatique" do
    visit admin_type_etablissement_diplomatiques_url
    page.accept_confirm do
      click_on "Destroy", match: :first
    end

    assert_text "Type etablissement diplomatique was successfully destroyed"
  end
end
