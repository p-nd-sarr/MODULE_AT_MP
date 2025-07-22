require "application_system_test_case"

class AllocationPostnatalesTest < ApplicationSystemTestCase
  setup do
    @allocation_postnatale = allocation_postnatales(:one)
  end

  test "visiting the index" do
    visit allocation_postnatales_url
    assert_selector "h1", text: "Allocation Postnatales"
  end

  test "creating a Allocation postnatale" do
    visit allocation_postnatales_url
    click_on "New Allocation Postnatale"

    fill_in "Ajoute par", with: @allocation_postnatale.ajoute_par_id
    fill_in "Commentaire", with: @allocation_postnatale.commentaire
    fill_in "Date accouchement", with: @allocation_postnatale.date_accouchement
    fill_in "Date soumission", with: @allocation_postnatale.date_soumission
    fill_in "Date validation", with: @allocation_postnatale.date_validation
    fill_in "Dossier prestation", with: @allocation_postnatale.dossier_prestation_id
    fill_in "Etat", with: @allocation_postnatale.etat
    fill_in "Montant paiement", with: @allocation_postnatale.montant_paiement
    fill_in "Motif rejet,", with: @allocation_postnatale.motif_rejet
    fill_in "Paiement", with: @allocation_postnatale.paiement
    fill_in "Traite le", with: @allocation_postnatale.traite_le
    fill_in "Traite par", with: @allocation_postnatale.traite_par_id
    fill_in "User", with: @allocation_postnatale.user
    fill_in "Valide par", with: @allocation_postnatale.valide_par_id
    fill_in "Volet", with: @allocation_postnatale.volet
    click_on "Create Allocation postnatale"

    assert_text "Allocation postnatale was successfully created"
    click_on "Back"
  end

  test "updating a Allocation postnatale" do
    visit allocation_postnatales_url
    click_on "Edit", match: :first

    fill_in "Ajoute par", with: @allocation_postnatale.ajoute_par_id
    fill_in "Commentaire", with: @allocation_postnatale.commentaire
    fill_in "Date accouchement", with: @allocation_postnatale.date_accouchement
    fill_in "Date soumission", with: @allocation_postnatale.date_soumission
    fill_in "Date validation", with: @allocation_postnatale.date_validation
    fill_in "Dossier prestation", with: @allocation_postnatale.dossier_prestation_id
    fill_in "Etat", with: @allocation_postnatale.etat
    fill_in "Montant paiement", with: @allocation_postnatale.montant_paiement
    fill_in "Motif rejet,", with: @allocation_postnatale.motif_rejet
    fill_in "Paiement", with: @allocation_postnatale.paiement
    fill_in "Traite le", with: @allocation_postnatale.traite_le
    fill_in "Traite par", with: @allocation_postnatale.traite_par_id
    fill_in "User", with: @allocation_postnatale.user
    fill_in "Valide par", with: @allocation_postnatale.valide_par_id
    fill_in "Volet", with: @allocation_postnatale.volet
    click_on "Update Allocation postnatale"

    assert_text "Allocation postnatale was successfully updated"
    click_on "Back"
  end

  test "destroying a Allocation postnatale" do
    visit allocation_postnatales_url
    page.accept_confirm do
      click_on "Destroy", match: :first
    end

    assert_text "Allocation postnatale was successfully destroyed"
  end
end
