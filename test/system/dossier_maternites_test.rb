require "application_system_test_case"

class DossierMaternitesTest < ApplicationSystemTestCase
  setup do
    @dossier_maternite = dossier_maternites(:one)
  end

  test "visiting the index" do
    visit dossier_maternites_url
    assert_selector "h1", text: "Dossier Maternites"
  end

  test "creating a Dossier maternite" do
    visit dossier_maternites_url
    click_on "New Dossier Maternite"

    fill_in "Adresse domicile", with: @dossier_maternite.adresse_domicile
    fill_in "Ajoute par", with: @dossier_maternite.ajoute_par_id
    check "Carriere valid" if @dossier_maternite.carriere_valid
    fill_in "Date naissance", with: @dossier_maternite.date_naissance
    fill_in "Date soumission", with: @dossier_maternite.date_soumission
    fill_in "Debut grossesse", with: @dossier_maternite.debut_grossesse
    check "Document valid" if @dossier_maternite.document_valid
    fill_in "Etat", with: @dossier_maternite.etat
    check "Etat civil demandeur valid" if @dossier_maternite.etat_civil_demandeur_valid
    fill_in "Lieu naissance", with: @dossier_maternite.lieu_naissance
    fill_in "Motif rejet", with: @dossier_maternite.motif_rejet
    fill_in "Nom", with: @dossier_maternite.nom
    fill_in "Num affiliation", with: @dossier_maternite.num_affiliation
    fill_in "Num dossier", with: @dossier_maternite.num_dossier
    fill_in "Prenom", with: @dossier_maternite.prenom
    fill_in "Traite le", with: @dossier_maternite.traite_le
    fill_in "Traite par", with: @dossier_maternite.traite_par_id
    fill_in "User", with: @dossier_maternite.user_id
    click_on "Create Dossier maternite"

    assert_text "Dossier maternite was successfully created"
    click_on "Back"
  end

  test "updating a Dossier maternite" do
    visit dossier_maternites_url
    click_on "Edit", match: :first

    fill_in "Adresse domicile", with: @dossier_maternite.adresse_domicile
    fill_in "Ajoute par", with: @dossier_maternite.ajoute_par_id
    check "Carriere valid" if @dossier_maternite.carriere_valid
    fill_in "Date naissance", with: @dossier_maternite.date_naissance
    fill_in "Date soumission", with: @dossier_maternite.date_soumission
    fill_in "Debut grossesse", with: @dossier_maternite.debut_grossesse
    check "Document valid" if @dossier_maternite.document_valid
    fill_in "Etat", with: @dossier_maternite.etat
    check "Etat civil demandeur valid" if @dossier_maternite.etat_civil_demandeur_valid
    fill_in "Lieu naissance", with: @dossier_maternite.lieu_naissance
    fill_in "Motif rejet", with: @dossier_maternite.motif_rejet
    fill_in "Nom", with: @dossier_maternite.nom
    fill_in "Num affiliation", with: @dossier_maternite.num_affiliation
    fill_in "Num dossier", with: @dossier_maternite.num_dossier
    fill_in "Prenom", with: @dossier_maternite.prenom
    fill_in "Traite le", with: @dossier_maternite.traite_le
    fill_in "Traite par", with: @dossier_maternite.traite_par_id
    fill_in "User", with: @dossier_maternite.user_id
    click_on "Update Dossier maternite"

    assert_text "Dossier maternite was successfully updated"
    click_on "Back"
  end

  test "destroying a Dossier maternite" do
    visit dossier_maternites_url
    page.accept_confirm do
      click_on "Destroy", match: :first
    end

    assert_text "Dossier maternite was successfully destroyed"
  end
end
