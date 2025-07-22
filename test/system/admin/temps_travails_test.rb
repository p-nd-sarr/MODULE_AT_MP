require "application_system_test_case"

class Admin::TempsTravailsTest < ApplicationSystemTestCase
  setup do
    @admin_temps_travail = admin_temps_travails(:one)
  end

  test "visiting the index" do
    visit admin_temps_travails_url
    assert_selector "h1", text: "Admin/Temps Travails"
  end

  test "creating a Temps travail" do
    visit admin_temps_travails_url
    click_on "New Admin/Temps Travail"

    fill_in "Code", with: @admin_temps_travail.code
    fill_in "Description", with: @admin_temps_travail.description
    click_on "Create Temps travail"

    assert_text "Temps travail was successfully created"
    click_on "Back"
  end

  test "updating a Temps travail" do
    visit admin_temps_travails_url
    click_on "Edit", match: :first

    fill_in "Code", with: @admin_temps_travail.code
    fill_in "Description", with: @admin_temps_travail.description
    click_on "Update Temps travail"

    assert_text "Temps travail was successfully updated"
    click_on "Back"
  end

  test "destroying a Temps travail" do
    visit admin_temps_travails_url
    page.accept_confirm do
      click_on "Destroy", match: :first
    end

    assert_text "Temps travail was successfully destroyed"
  end
end
