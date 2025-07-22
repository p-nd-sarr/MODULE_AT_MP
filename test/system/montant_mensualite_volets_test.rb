require "application_system_test_case"

class MontantMensualiteVoletsTest < ApplicationSystemTestCase
  setup do
    @montant_mensualite_volet = montant_mensualite_volets(:one)
  end

  test "visiting the index" do
    visit montant_mensualite_volets_url
    assert_selector "h1", text: "Montant Mensualite Volets"
  end

  test "creating a Montant mensualite volet" do
    visit montant_mensualite_volets_url
    click_on "New Montant Mensualite Volet"

    fill_in "Allocation prenatale", with: @montant_mensualite_volet.allocation_prenatale_id
    fill_in "Date changement", with: @montant_mensualite_volet.date_changement
    fill_in "Montant", with: @montant_mensualite_volet.montant
    fill_in "Num volet", with: @montant_mensualite_volet.num_volet
    click_on "Create Montant mensualite volet"

    assert_text "Montant mensualite volet was successfully created"
    click_on "Back"
  end

  test "updating a Montant mensualite volet" do
    visit montant_mensualite_volets_url
    click_on "Edit", match: :first

    fill_in "Allocation prenatale", with: @montant_mensualite_volet.allocation_prenatale_id
    fill_in "Date changement", with: @montant_mensualite_volet.date_changement
    fill_in "Montant", with: @montant_mensualite_volet.montant
    fill_in "Num volet", with: @montant_mensualite_volet.num_volet
    click_on "Update Montant mensualite volet"

    assert_text "Montant mensualite volet was successfully updated"
    click_on "Back"
  end

  test "destroying a Montant mensualite volet" do
    visit montant_mensualite_volets_url
    page.accept_confirm do
      click_on "Destroy", match: :first
    end

    assert_text "Montant mensualite volet was successfully destroyed"
  end
end
