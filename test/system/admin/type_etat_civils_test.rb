require "application_system_test_case"

class Admin::TypeEtatCivilsTest < ApplicationSystemTestCase
  setup do
    @admin_type_etat_civil = admin_type_etat_civils(:one)
  end

  test "visiting the index" do
    visit admin_type_etat_civils_url
    assert_selector "h1", text: "Admin/Type Etat Civils"
  end

  test "creating a Type etat civil" do
    visit admin_type_etat_civils_url
    click_on "New Admin/Type Etat Civil"

    fill_in "Code", with: @admin_type_etat_civil.code
    fill_in "Description", with: @admin_type_etat_civil.description
    click_on "Create Type etat civil"

    assert_text "Type etat civil was successfully created"
    click_on "Back"
  end

  test "updating a Type etat civil" do
    visit admin_type_etat_civils_url
    click_on "Edit", match: :first

    fill_in "Code", with: @admin_type_etat_civil.code
    fill_in "Description", with: @admin_type_etat_civil.description
    click_on "Update Type etat civil"

    assert_text "Type etat civil was successfully updated"
    click_on "Back"
  end

  test "destroying a Type etat civil" do
    visit admin_type_etat_civils_url
    page.accept_confirm do
      click_on "Destroy", match: :first
    end

    assert_text "Type etat civil was successfully destroyed"
  end
end
