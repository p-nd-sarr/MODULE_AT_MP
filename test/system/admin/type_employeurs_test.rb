require "application_system_test_case"

class Admin::TypeEmployeursTest < ApplicationSystemTestCase
  setup do
    @admin_type_employeur = admin_type_employeurs(:one)
  end

  test "visiting the index" do
    visit admin_type_employeurs_url
    assert_selector "h1", text: "Admin/Type Employeurs"
  end

  test "creating a Type employeur" do
    visit admin_type_employeurs_url
    click_on "New Admin/Type Employeur"

    fill_in "Code", with: @admin_type_employeur.code
    fill_in "Description", with: @admin_type_employeur.description
    click_on "Create Type employeur"

    assert_text "Type employeur was successfully created"
    click_on "Back"
  end

  test "updating a Type employeur" do
    visit admin_type_employeurs_url
    click_on "Edit", match: :first

    fill_in "Code", with: @admin_type_employeur.code
    fill_in "Description", with: @admin_type_employeur.description
    click_on "Update Type employeur"

    assert_text "Type employeur was successfully updated"
    click_on "Back"
  end

  test "destroying a Type employeur" do
    visit admin_type_employeurs_url
    page.accept_confirm do
      click_on "Destroy", match: :first
    end

    assert_text "Type employeur was successfully destroyed"
  end
end
