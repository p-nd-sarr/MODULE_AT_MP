require "application_system_test_case"

class Admin::ProfessionsTest < ApplicationSystemTestCase
  setup do
    @admin_profession = admin_professions(:one)
  end

  test "visiting the index" do
    visit admin_professions_url
    assert_selector "h1", text: "Admin/Professions"
  end

  test "creating a Profession" do
    visit admin_professions_url
    click_on "New Admin/Profession"

    fill_in "Code", with: @admin_profession.code
    fill_in "Description", with: @admin_profession.description
    click_on "Create Profession"

    assert_text "Profession was successfully created"
    click_on "Back"
  end

  test "updating a Profession" do
    visit admin_professions_url
    click_on "Edit", match: :first

    fill_in "Code", with: @admin_profession.code
    fill_in "Description", with: @admin_profession.description
    click_on "Update Profession"

    assert_text "Profession was successfully updated"
    click_on "Back"
  end

  test "destroying a Profession" do
    visit admin_professions_url
    page.accept_confirm do
      click_on "Destroy", match: :first
    end

    assert_text "Profession was successfully destroyed"
  end
end
