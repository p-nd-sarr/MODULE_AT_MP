require "application_system_test_case"

class Salarie::EnfantsTest < ApplicationSystemTestCase
  setup do
    @salarie_enfant = salarie_enfants(:one)
  end

  test "visiting the index" do
    visit salarie_enfants_url
    assert_selector "h1", text: "Salarie/Enfants"
  end

  test "creating a Enfant" do
    visit salarie_enfants_url
    click_on "New Salarie/Enfant"

    fill_in "Date naissance", with: @salarie_enfant.date_naissance
    fill_in "Nom", with: @salarie_enfant.nom
    fill_in "Nom mere", with: @salarie_enfant.nom_mere
    fill_in "Nom pere", with: @salarie_enfant.nom_pere
    fill_in "Prenom", with: @salarie_enfant.prenom
    fill_in "Prenom mere", with: @salarie_enfant.prenom_mere
    fill_in "Prenom pere", with: @salarie_enfant.prenom_pere
    click_on "Create Enfant"

    assert_text "Enfant was successfully created"
    click_on "Back"
  end

  test "updating a Enfant" do
    visit salarie_enfants_url
    click_on "Edit", match: :first

    fill_in "Date naissance", with: @salarie_enfant.date_naissance
    fill_in "Nom", with: @salarie_enfant.nom
    fill_in "Nom mere", with: @salarie_enfant.nom_mere
    fill_in "Nom pere", with: @salarie_enfant.nom_pere
    fill_in "Prenom", with: @salarie_enfant.prenom
    fill_in "Prenom mere", with: @salarie_enfant.prenom_mere
    fill_in "Prenom pere", with: @salarie_enfant.prenom_pere
    click_on "Update Enfant"

    assert_text "Enfant was successfully updated"
    click_on "Back"
  end

  test "destroying a Enfant" do
    visit salarie_enfants_url
    page.accept_confirm do
      click_on "Destroy", match: :first
    end

    assert_text "Enfant was successfully destroyed"
  end
end
