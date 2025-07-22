require "application_system_test_case"

class Admin::TypeEtablissementsTest < ApplicationSystemTestCase
  setup do
    @admin_type_etablissement = admin_type_etablissements(:one)
  end

  test "visiting the index" do
    visit admin_type_etablissements_url
    assert_selector "h1", text: "Admin/Type Etablissements"
  end

  test "creating a Type etablissement" do
    visit admin_type_etablissements_url
    click_on "New Admin/Type Etablissement"

    fill_in "Code", with: @admin_type_etablissement.code
    fill_in "Description", with: @admin_type_etablissement.description
    click_on "Create Type etablissement"

    assert_text "Type etablissement was successfully created"
    click_on "Back"
  end

  test "updating a Type etablissement" do
    visit admin_type_etablissements_url
    click_on "Edit", match: :first

    fill_in "Code", with: @admin_type_etablissement.code
    fill_in "Description", with: @admin_type_etablissement.description
    click_on "Update Type etablissement"

    assert_text "Type etablissement was successfully updated"
    click_on "Back"
  end

  test "destroying a Type etablissement" do
    visit admin_type_etablissements_url
    page.accept_confirm do
      click_on "Destroy", match: :first
    end

    assert_text "Type etablissement was successfully destroyed"
  end
end
