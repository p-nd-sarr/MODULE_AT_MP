require "application_system_test_case"

class AllocationFamilialesTest < ApplicationSystemTestCase
  setup do
    @allocation_familiale = allocation_familiales(:one)
  end

  test "visiting the index" do
    visit allocation_familiales_url
    assert_selector "h1", text: "Allocation Familiales"
  end

  test "creating a Allocation familiale" do
    visit allocation_familiales_url
    click_on "New Allocation Familiale"

    fill_in "Ajoute par", with: @allocation_familiale.ajoute_par_id
    fill_in "Annee", with: @allocation_familiale.annee
    fill_in "Date soumission", with: @allocation_familiale.date_soumission
    fill_in "Date validation", with: @allocation_familiale.date_validation
    fill_in "Dossier prestation", with: @allocation_familiale.dossier_prestation_id
    fill_in "Enfant", with: @allocation_familiale.enfant_id
    fill_in "Etat", with: @allocation_familiale.etat
    fill_in "Montant paiement", with: @allocation_familiale.montant_paiement
    fill_in "Motif rejet", with: @allocation_familiale.motif_rejet
    check "Paiement" if @allocation_familiale.paiement
    fill_in "Traite le", with: @allocation_familiale.traite_le
    fill_in "Traite par", with: @allocation_familiale.traite_par_id
    fill_in "Trimestre", with: @allocation_familiale.trimestre
    fill_in "User", with: @allocation_familiale.user_id
    fill_in "Valide par", with: @allocation_familiale.valide_par_id
    click_on "Create Allocation familiale"

    assert_text "Allocation familiale was successfully created"
    click_on "Back"
  end

  test "updating a Allocation familiale" do
    visit allocation_familiales_url
    click_on "Edit", match: :first

    fill_in "Ajoute par", with: @allocation_familiale.ajoute_par_id
    fill_in "Annee", with: @allocation_familiale.annee
    fill_in "Date soumission", with: @allocation_familiale.date_soumission
    fill_in "Date validation", with: @allocation_familiale.date_validation
    fill_in "Dossier prestation", with: @allocation_familiale.dossier_prestation_id
    fill_in "Enfant", with: @allocation_familiale.enfant_id
    fill_in "Etat", with: @allocation_familiale.etat
    fill_in "Montant paiement", with: @allocation_familiale.montant_paiement
    fill_in "Motif rejet", with: @allocation_familiale.motif_rejet
    check "Paiement" if @allocation_familiale.paiement
    fill_in "Traite le", with: @allocation_familiale.traite_le
    fill_in "Traite par", with: @allocation_familiale.traite_par_id
    fill_in "Trimestre", with: @allocation_familiale.trimestre
    fill_in "User", with: @allocation_familiale.user_id
    fill_in "Valide par", with: @allocation_familiale.valide_par_id
    click_on "Update Allocation familiale"

    assert_text "Allocation familiale was successfully updated"
    click_on "Back"
  end

  test "destroying a Allocation familiale" do
    visit allocation_familiales_url
    page.accept_confirm do
      click_on "Destroy", match: :first
    end

    assert_text "Allocation familiale was successfully destroyed"
  end
end
