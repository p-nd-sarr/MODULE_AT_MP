require "application_system_test_case"

class Admin::TypePieceIdentificationsTest < ApplicationSystemTestCase
  setup do
    @admin_type_piece_identification = admin_type_piece_identifications(:one)
  end

  test "visiting the index" do
    visit admin_type_piece_identifications_url
    assert_selector "h1", text: "Admin/Type Piece Identifications"
  end

  test "creating a Type piece identification" do
    visit admin_type_piece_identifications_url
    click_on "New Admin/Type Piece Identification"

    fill_in "Code", with: @admin_type_piece_identification.code
    fill_in "Description", with: @admin_type_piece_identification.description
    click_on "Create Type piece identification"

    assert_text "Type piece identification was successfully created"
    click_on "Back"
  end

  test "updating a Type piece identification" do
    visit admin_type_piece_identifications_url
    click_on "Edit", match: :first

    fill_in "Code", with: @admin_type_piece_identification.code
    fill_in "Description", with: @admin_type_piece_identification.description
    click_on "Update Type piece identification"

    assert_text "Type piece identification was successfully updated"
    click_on "Back"
  end

  test "destroying a Type piece identification" do
    visit admin_type_piece_identifications_url
    page.accept_confirm do
      click_on "Destroy", match: :first
    end

    assert_text "Type piece identification was successfully destroyed"
  end
end
