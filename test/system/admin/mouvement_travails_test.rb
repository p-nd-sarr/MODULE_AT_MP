require "application_system_test_case"

class Admin::MouvementTravailsTest < ApplicationSystemTestCase
  setup do
    @admin_mouvement_travail = admin_mouvement_travails(:one)
  end

  test "visiting the index" do
    visit admin_mouvement_travails_url
    assert_selector "h1", text: "Admin/Mouvement Travails"
  end

  test "creating a Mouvement travail" do
    visit admin_mouvement_travails_url
    click_on "New Admin/Mouvement Travail"

    fill_in "Code", with: @admin_mouvement_travail.code
    fill_in "Description", with: @admin_mouvement_travail.description
    click_on "Create Mouvement travail"

    assert_text "Mouvement travail was successfully created"
    click_on "Back"
  end

  test "updating a Mouvement travail" do
    visit admin_mouvement_travails_url
    click_on "Edit", match: :first

    fill_in "Code", with: @admin_mouvement_travail.code
    fill_in "Description", with: @admin_mouvement_travail.description
    click_on "Update Mouvement travail"

    assert_text "Mouvement travail was successfully updated"
    click_on "Back"
  end

  test "destroying a Mouvement travail" do
    visit admin_mouvement_travails_url
    page.accept_confirm do
      click_on "Destroy", match: :first
    end

    assert_text "Mouvement travail was successfully destroyed"
  end
end
