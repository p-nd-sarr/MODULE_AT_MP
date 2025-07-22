require "application_system_test_case"

class Admin::MotifSortiesTest < ApplicationSystemTestCase
  setup do
    @admin_motif_sortie = admin_motif_sorties(:one)
  end

  test "visiting the index" do
    visit admin_motif_sorties_url
    assert_selector "h1", text: "Admin/Motif Sorties"
  end

  test "creating a Motif sortie" do
    visit admin_motif_sorties_url
    click_on "New Admin/Motif Sortie"

    fill_in "Code", with: @admin_motif_sortie.code
    fill_in "Description", with: @admin_motif_sortie.description
    click_on "Create Motif sortie"

    assert_text "Motif sortie was successfully created"
    click_on "Back"
  end

  test "updating a Motif sortie" do
    visit admin_motif_sorties_url
    click_on "Edit", match: :first

    fill_in "Code", with: @admin_motif_sortie.code
    fill_in "Description", with: @admin_motif_sortie.description
    click_on "Update Motif sortie"

    assert_text "Motif sortie was successfully updated"
    click_on "Back"
  end

  test "destroying a Motif sortie" do
    visit admin_motif_sorties_url
    page.accept_confirm do
      click_on "Destroy", match: :first
    end

    assert_text "Motif sortie was successfully destroyed"
  end
end
