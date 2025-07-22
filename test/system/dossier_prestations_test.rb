require "application_system_test_case"

class DossierPrestationsTest < ApplicationSystemTestCase
  setup do
    @dossier_prestation = dossier_prestations(:one)
  end

  test "visiting the index" do
    visit dossier_prestations_url
    assert_selector "h1", text: "Dossier Prestations"
  end

  test "creating a Dossier prestation" do
    visit dossier_prestations_url
    click_on "New Dossier Prestation"

    fill_in "Adresse domicile", with: @dossier_prestation.adresse_domicile
    check "Carriere valid" if @dossier_prestation.carriere_valid
    check "Conjoint valid" if @dossier_prestation.conjoint_valid
    fill_in "Date naissance", with: @dossier_prestation.date_naissance
    fill_in "Date soumission", with: @dossier_prestation.date_soumission
    fill_in "Date validation", with: @dossier_prestation.date_validation
    check "Document valid" if @dossier_prestation.document_valid
    check "Enfants valid" if @dossier_prestation.enfants_valid
    fill_in "Etat", with: @dossier_prestation.etat
    check "Etat civil demandeur valid" if @dossier_prestation.etat_civil_demandeur_valid
    fill_in "Lieu naissance", with: @dossier_prestation.lieu_naissance
    fill_in "Nom", with: @dossier_prestation.nom
    fill_in "Num affiliation", with: @dossier_prestation.num_affiliation
    fill_in "Prenom", with: @dossier_prestation.prenom
    fill_in "Sexe salarie", with: @dossier_prestation.sexe_salarie
    fill_in "User", with: @dossier_prestation.user_id
    fill_in "Valide par", with: @dossier_prestation.valide_par_id
    click_on "Create Dossier prestation"

    assert_text "Dossier prestation was successfully created"
    click_on "Back"
  end

  test "updating a Dossier prestation" do
    visit dossier_prestations_url
    click_on "Edit", match: :first

    fill_in "Adresse domicile", with: @dossier_prestation.adresse_domicile
    check "Carriere valid" if @dossier_prestation.carriere_valid
    check "Conjoint valid" if @dossier_prestation.conjoint_valid
    fill_in "Date naissance", with: @dossier_prestation.date_naissance
    fill_in "Date soumission", with: @dossier_prestation.date_soumission
    fill_in "Date validation", with: @dossier_prestation.date_validation
    check "Document valid" if @dossier_prestation.document_valid
    check "Enfants valid" if @dossier_prestation.enfants_valid
    fill_in "Etat", with: @dossier_prestation.etat
    check "Etat civil demandeur valid" if @dossier_prestation.etat_civil_demandeur_valid
    fill_in "Lieu naissance", with: @dossier_prestation.lieu_naissance
    fill_in "Nom", with: @dossier_prestation.nom
    fill_in "Num affiliation", with: @dossier_prestation.num_affiliation
    fill_in "Prenom", with: @dossier_prestation.prenom
    fill_in "Sexe salarie", with: @dossier_prestation.sexe_salarie
    fill_in "User", with: @dossier_prestation.user_id
    fill_in "Valide par", with: @dossier_prestation.valide_par_id
    click_on "Update Dossier prestation"

    assert_text "Dossier prestation was successfully updated"
    click_on "Back"
  end

  test "destroying a Dossier prestation" do
    visit dossier_prestations_url
    page.accept_confirm do
      click_on "Destroy", match: :first
    end

    assert_text "Dossier prestation was successfully destroyed"
  end
end
