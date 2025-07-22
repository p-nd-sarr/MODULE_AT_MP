require "application_system_test_case"

class IndemniteCongesMaternitesTest < ApplicationSystemTestCase
  setup do
    @indemnite_conges_maternite = indemnite_conges_maternites(:one)
  end

  test "visiting the index" do
    visit indemnite_conges_maternites_url
    assert_selector "h1", text: "Indemnite Conges Maternites"
  end

  test "creating a Indemnite conges maternite" do
    visit indemnite_conges_maternites_url
    click_on "New Indemnite Conges Maternite"

    fill_in "Ajoute par", with: @indemnite_conges_maternite.ajoute_par_id
    fill_in "Date accouchement", with: @indemnite_conges_maternite.date_accouchement
    fill_in "Date reprise service", with: @indemnite_conges_maternite.date_reprise_service
    fill_in "Date soumission", with: @indemnite_conges_maternite.date_soumission
    fill_in "Date validation", with: @indemnite_conges_maternite.date_validation
    fill_in "Debut conges", with: @indemnite_conges_maternite.debut_conges
    fill_in "Debut grossesse", with: @indemnite_conges_maternite.debut_grossesse
    fill_in "Dossier prestation", with: @indemnite_conges_maternite.dossier_prestation_id
    fill_in "Etat", with: @indemnite_conges_maternite.etat
    fill_in "Montant paiement", with: @indemnite_conges_maternite.montant_paiement
    fill_in "Motif rejet", with: @indemnite_conges_maternite.motif_rejet
    check "Paiement" if @indemnite_conges_maternite.paiement
    fill_in "Traite le", with: @indemnite_conges_maternite.traite_le
    fill_in "Traite par", with: @indemnite_conges_maternite.traite_par_id
    fill_in "Tranche paiement", with: @indemnite_conges_maternite.tranche_paiement
    fill_in "User", with: @indemnite_conges_maternite.user_id
    fill_in "Valide par", with: @indemnite_conges_maternite.valide_par_id
    click_on "Create Indemnite conges maternite"

    assert_text "Indemnite conges maternite was successfully created"
    click_on "Back"
  end

  test "updating a Indemnite conges maternite" do
    visit indemnite_conges_maternites_url
    click_on "Edit", match: :first

    fill_in "Ajoute par", with: @indemnite_conges_maternite.ajoute_par_id
    fill_in "Date accouchement", with: @indemnite_conges_maternite.date_accouchement
    fill_in "Date reprise service", with: @indemnite_conges_maternite.date_reprise_service
    fill_in "Date soumission", with: @indemnite_conges_maternite.date_soumission
    fill_in "Date validation", with: @indemnite_conges_maternite.date_validation
    fill_in "Debut conges", with: @indemnite_conges_maternite.debut_conges
    fill_in "Debut grossesse", with: @indemnite_conges_maternite.debut_grossesse
    fill_in "Dossier prestation", with: @indemnite_conges_maternite.dossier_prestation_id
    fill_in "Etat", with: @indemnite_conges_maternite.etat
    fill_in "Montant paiement", with: @indemnite_conges_maternite.montant_paiement
    fill_in "Motif rejet", with: @indemnite_conges_maternite.motif_rejet
    check "Paiement" if @indemnite_conges_maternite.paiement
    fill_in "Traite le", with: @indemnite_conges_maternite.traite_le
    fill_in "Traite par", with: @indemnite_conges_maternite.traite_par_id
    fill_in "Tranche paiement", with: @indemnite_conges_maternite.tranche_paiement
    fill_in "User", with: @indemnite_conges_maternite.user_id
    fill_in "Valide par", with: @indemnite_conges_maternite.valide_par_id
    click_on "Update Indemnite conges maternite"

    assert_text "Indemnite conges maternite was successfully updated"
    click_on "Back"
  end

  test "destroying a Indemnite conges maternite" do
    visit indemnite_conges_maternites_url
    page.accept_confirm do
      click_on "Destroy", match: :first
    end

    assert_text "Indemnite conges maternite was successfully destroyed"
  end
end
