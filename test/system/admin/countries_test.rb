require "application_system_test_case"

class Admin::CountriesTest < ApplicationSystemTestCase
  setup do
    @admin_country = admin_countries(:one)
  end

  test "visiting the index" do
    visit admin_countries_url
    assert_selector "h1", text: "Admin/Countries"
  end

  test "creating a Country" do
    visit admin_countries_url
    click_on "New Admin/Country"

    fill_in "Code", with: @admin_country.code
    fill_in "Description", with: @admin_country.description
    click_on "Create Country"

    assert_text "Country was successfully created"
    click_on "Back"
  end

  test "updating a Country" do
    visit admin_countries_url
    click_on "Edit", match: :first

    fill_in "Code", with: @admin_country.code
    fill_in "Description", with: @admin_country.description
    click_on "Update Country"

    assert_text "Country was successfully updated"
    click_on "Back"
  end

  test "destroying a Country" do
    visit admin_countries_url
    page.accept_confirm do
      click_on "Destroy", match: :first
    end

    assert_text "Country was successfully destroyed"
  end
end
