require "application_system_test_case"

class Admin::ConventionCollectivesTest < ApplicationSystemTestCase
  setup do
    @admin_convention_collective = admin_convention_collectives(:one)
  end

  test "visiting the index" do
    visit admin_convention_collectives_url
    assert_selector "h1", text: "Admin/Convention Collectives"
  end

  test "creating a Convention collective" do
    visit admin_convention_collectives_url
    click_on "New Admin/Convention Collective"

    fill_in "Code", with: @admin_convention_collective.code
    fill_in "Description", with: @admin_convention_collective.description
    click_on "Create Convention collective"

    assert_text "Convention collective was successfully created"
    click_on "Back"
  end

  test "updating a Convention collective" do
    visit admin_convention_collectives_url
    click_on "Edit", match: :first

    fill_in "Code", with: @admin_convention_collective.code
    fill_in "Description", with: @admin_convention_collective.description
    click_on "Update Convention collective"

    assert_text "Convention collective was successfully updated"
    click_on "Back"
  end

  test "destroying a Convention collective" do
    visit admin_convention_collectives_url
    page.accept_confirm do
      click_on "Destroy", match: :first
    end

    assert_text "Convention collective was successfully destroyed"
  end
end
