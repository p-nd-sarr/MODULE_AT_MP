require "application_system_test_case"

class Admin::JourOuvrableAnnuelsTest < ApplicationSystemTestCase
  setup do
    @admin_jour_ouvrable_annuel = admin_jour_ouvrable_annuels(:one)
  end

  test "visiting the index" do
    visit admin_jour_ouvrable_annuels_url
    assert_selector "h1", text: "Admin/Jour Ouvrable Annuels"
  end

  test "creating a Jour ouvrable annuel" do
    visit admin_jour_ouvrable_annuels_url
    click_on "New Admin/Jour Ouvrable Annuel"

    fill_in "Mois", with: @admin_jour_ouvrable_annuel.mois
    fill_in "Mois en chiffre", with: @admin_jour_ouvrable_annuel.mois_en_chiffre
    fill_in "Nombre jour ouvrable", with: @admin_jour_ouvrable_annuel.nombre_jour_ouvrable
    click_on "Create Jour ouvrable annuel"

    assert_text "Jour ouvrable annuel was successfully created"
    click_on "Back"
  end

  test "updating a Jour ouvrable annuel" do
    visit admin_jour_ouvrable_annuels_url
    click_on "Edit", match: :first

    fill_in "Mois", with: @admin_jour_ouvrable_annuel.mois
    fill_in "Mois en chiffre", with: @admin_jour_ouvrable_annuel.mois_en_chiffre
    fill_in "Nombre jour ouvrable", with: @admin_jour_ouvrable_annuel.nombre_jour_ouvrable
    click_on "Update Jour ouvrable annuel"

    assert_text "Jour ouvrable annuel was successfully updated"
    click_on "Back"
  end

  test "destroying a Jour ouvrable annuel" do
    visit admin_jour_ouvrable_annuels_url
    page.accept_confirm do
      click_on "Destroy", match: :first
    end

    assert_text "Jour ouvrable annuel was successfully destroyed"
  end
end
