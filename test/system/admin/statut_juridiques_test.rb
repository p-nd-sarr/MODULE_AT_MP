require "application_system_test_case"

class Admin::StatutJuridiquesTest < ApplicationSystemTestCase
  setup do
    @admin_statut_juridique = admin_statut_juridiques(:one)
  end

  test "visiting the index" do
    visit admin_statut_juridiques_url
    assert_selector "h1", text: "Admin/Statut Juridiques"
  end

  test "creating a Statut juridique" do
    visit admin_statut_juridiques_url
    click_on "New Admin/Statut Juridique"

    fill_in "Code", with: @admin_statut_juridique.code
    fill_in "Description", with: @admin_statut_juridique.description
    click_on "Create Statut juridique"

    assert_text "Statut juridique was successfully created"
    click_on "Back"
  end

  test "updating a Statut juridique" do
    visit admin_statut_juridiques_url
    click_on "Edit", match: :first

    fill_in "Code", with: @admin_statut_juridique.code
    fill_in "Description", with: @admin_statut_juridique.description
    click_on "Update Statut juridique"

    assert_text "Statut juridique was successfully updated"
    click_on "Back"
  end

  test "destroying a Statut juridique" do
    visit admin_statut_juridiques_url
    page.accept_confirm do
      click_on "Destroy", match: :first
    end

    assert_text "Statut juridique was successfully destroyed"
  end
end
