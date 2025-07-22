require "application_system_test_case"

class Admin::TypeStatutJuridiquesTest < ApplicationSystemTestCase
  setup do
    @admin_type_statut_juridique = admin_type_statut_juridiques(:one)
  end

  test "visiting the index" do
    visit admin_type_statut_juridiques_url
    assert_selector "h1", text: "Admin/Type Statut Juridiques"
  end

  test "creating a Type statut juridique" do
    visit admin_type_statut_juridiques_url
    click_on "New Admin/Type Statut Juridique"

    fill_in "Code", with: @admin_type_statut_juridique.code
    fill_in "Description", with: @admin_type_statut_juridique.description
    click_on "Create Type statut juridique"

    assert_text "Type statut juridique was successfully created"
    click_on "Back"
  end

  test "updating a Type statut juridique" do
    visit admin_type_statut_juridiques_url
    click_on "Edit", match: :first

    fill_in "Code", with: @admin_type_statut_juridique.code
    fill_in "Description", with: @admin_type_statut_juridique.description
    click_on "Update Type statut juridique"

    assert_text "Type statut juridique was successfully updated"
    click_on "Back"
  end

  test "destroying a Type statut juridique" do
    visit admin_type_statut_juridiques_url
    page.accept_confirm do
      click_on "Destroy", match: :first
    end

    assert_text "Type statut juridique was successfully destroyed"
  end
end
