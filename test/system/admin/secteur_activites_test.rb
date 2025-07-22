require "application_system_test_case"

class Admin::SecteurActivitesTest < ApplicationSystemTestCase
  setup do
    @admin_secteur_activite = admin_secteur_activites(:one)
  end

  test "visiting the index" do
    visit admin_secteur_activites_url
    assert_selector "h1", text: "Admin/Secteur Activites"
  end

  test "creating a Secteur activite" do
    visit admin_secteur_activites_url
    click_on "New Admin/Secteur Activite"

    fill_in "Description", with: @admin_secteur_activite.description
    click_on "Create Secteur activite"

    assert_text "Secteur activite was successfully created"
    click_on "Back"
  end

  test "updating a Secteur activite" do
    visit admin_secteur_activites_url
    click_on "Edit", match: :first

    fill_in "Description", with: @admin_secteur_activite.description
    click_on "Update Secteur activite"

    assert_text "Secteur activite was successfully updated"
    click_on "Back"
  end

  test "destroying a Secteur activite" do
    visit admin_secteur_activites_url
    page.accept_confirm do
      click_on "Destroy", match: :first
    end

    assert_text "Secteur activite was successfully destroyed"
  end
end
