require "application_system_test_case"

class Admin::ActivitePrincipalesTest < ApplicationSystemTestCase
  setup do
    @admin_activite_principale = admin_activite_principales(:one)
  end

  test "visiting the index" do
    visit admin_activite_principales_url
    assert_selector "h1", text: "Admin/Activite Principales"
  end

  test "creating a Activite principale" do
    visit admin_activite_principales_url
    click_on "New Admin/Activite Principale"

    fill_in "Description", with: @admin_activite_principale.description
    fill_in "Secteur activite", with: @admin_activite_principale.secteur_activite_id
    click_on "Create Activite principale"

    assert_text "Activite principale was successfully created"
    click_on "Back"
  end

  test "updating a Activite principale" do
    visit admin_activite_principales_url
    click_on "Edit", match: :first

    fill_in "Description", with: @admin_activite_principale.description
    fill_in "Secteur activite", with: @admin_activite_principale.secteur_activite_id
    click_on "Update Activite principale"

    assert_text "Activite principale was successfully updated"
    click_on "Back"
  end

  test "destroying a Activite principale" do
    visit admin_activite_principales_url
    page.accept_confirm do
      click_on "Destroy", match: :first
    end

    assert_text "Activite principale was successfully destroyed"
  end
end
