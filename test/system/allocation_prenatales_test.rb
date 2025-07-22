require "application_system_test_case"

class AllocationPrenatalesTest < ApplicationSystemTestCase
  setup do
    @allocation_prenatale = allocation_prenatales(:one)
  end

  test "visiting the index" do
    visit allocation_prenatales_url
    assert_selector "h1", text: "Allocation Prenatales"
  end

  test "creating a Allocation prenatale" do
    visit allocation_prenatales_url
    click_on "New Allocation Prenatale"

    fill_in "Commentaire", with: @allocation_prenatale.commentaire
    fill_in "Date soumission", with: @allocation_prenatale.date_soumission
    fill_in "Date validation", with: @allocation_prenatale.date_validation
    fill_in "Debut grossesse", with: @allocation_prenatale.debut_grossesse
    fill_in "Dossier prestation", with: @allocation_prenatale.dossier_prestation_id
    fill_in "User", with: @allocation_prenatale.user_id
    fill_in "Valide par", with: @allocation_prenatale.valide_par_id
    fill_in "Volet", with: @allocation_prenatale.volet
    click_on "Create Allocation prenatale"

    assert_text "Allocation prenatale was successfully created"
    click_on "Back"
  end

  test "updating a Allocation prenatale" do
    visit allocation_prenatales_url
    click_on "Edit", match: :first

    fill_in "Commentaire", with: @allocation_prenatale.commentaire
    fill_in "Date soumission", with: @allocation_prenatale.date_soumission
    fill_in "Date validation", with: @allocation_prenatale.date_validation
    fill_in "Debut grossesse", with: @allocation_prenatale.debut_grossesse
    fill_in "Dossier prestation", with: @allocation_prenatale.dossier_prestation_id
    fill_in "User", with: @allocation_prenatale.user_id
    fill_in "Valide par", with: @allocation_prenatale.valide_par_id
    fill_in "Volet", with: @allocation_prenatale.volet
    click_on "Update Allocation prenatale"

    assert_text "Allocation prenatale was successfully updated"
    click_on "Back"
  end

  test "destroying a Allocation prenatale" do
    visit allocation_prenatales_url
    page.accept_confirm do
      click_on "Destroy", match: :first
    end

    assert_text "Allocation prenatale was successfully destroyed"
  end
end
