require "application_system_test_case"

class Admin::TypeContratSalariesTest < ApplicationSystemTestCase
  setup do
    @admin_type_contrat_salarie = admin_type_contrat_salaries(:one)
  end

  test "visiting the index" do
    visit admin_type_contrat_salaries_url
    assert_selector "h1", text: "Admin/Type Contrat Salaries"
  end

  test "creating a Type contrat salarie" do
    visit admin_type_contrat_salaries_url
    click_on "New Admin/Type Contrat Salarie"

    fill_in "Code", with: @admin_type_contrat_salarie.code
    fill_in "Description", with: @admin_type_contrat_salarie.description
    click_on "Create Type contrat salarie"

    assert_text "Type contrat salarie was successfully created"
    click_on "Back"
  end

  test "updating a Type contrat salarie" do
    visit admin_type_contrat_salaries_url
    click_on "Edit", match: :first

    fill_in "Code", with: @admin_type_contrat_salarie.code
    fill_in "Description", with: @admin_type_contrat_salarie.description
    click_on "Update Type contrat salarie"

    assert_text "Type contrat salarie was successfully updated"
    click_on "Back"
  end

  test "destroying a Type contrat salarie" do
    visit admin_type_contrat_salaries_url
    page.accept_confirm do
      click_on "Destroy", match: :first
    end

    assert_text "Type contrat salarie was successfully destroyed"
  end
end
