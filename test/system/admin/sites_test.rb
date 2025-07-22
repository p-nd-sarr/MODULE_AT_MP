require "application_system_test_case"

class Admin::SitesTest < ApplicationSystemTestCase
  setup do
    @admin_site = admin_sites(:one)
  end

  test "visiting the index" do
    visit admin_sites_url
    assert_selector "h1", text: "Admin/Sites"
  end

  test "creating a Site" do
    visit admin_sites_url
    click_on "New Admin/Site"

    fill_in "Code", with: @admin_site.code
    fill_in "Description", with: @admin_site.description
    click_on "Create Site"

    assert_text "Site was successfully created"
    click_on "Back"
  end

  test "updating a Site" do
    visit admin_sites_url
    click_on "Edit", match: :first

    fill_in "Code", with: @admin_site.code
    fill_in "Description", with: @admin_site.description
    click_on "Update Site"

    assert_text "Site was successfully updated"
    click_on "Back"
  end

  test "destroying a Site" do
    visit admin_sites_url
    page.accept_confirm do
      click_on "Destroy", match: :first
    end

    assert_text "Site was successfully destroyed"
  end
end
