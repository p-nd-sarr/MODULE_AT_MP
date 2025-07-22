require "application_system_test_case"

class DemandeLiquidationsTest < ApplicationSystemTestCase
  setup do
    @demande_liquidation = demande_liquidations(:one)
  end

  test "visiting the index" do
    visit demande_liquidations_url
    assert_selector "h1", text: "Demande Liquidations"
  end

  test "creating a Demande liquidation" do
    visit demande_liquidations_url
    click_on "New Demande Liquidation"

    fill_in "Adresse domicile", with: @demande_liquidation.adresse_domicile
    fill_in "Adresse reception allocation", with: @demande_liquidation.adresse_reception_allocation
    fill_in "Compte bancaire code banque", with: @demande_liquidation.compte_bancaire_code_banque
    fill_in "Compte bancaire code guichet", with: @demande_liquidation.compte_bancaire_code_guichet
    fill_in "Compte bancaire nom banque", with: @demande_liquidation.compte_bancaire_nom_banque
    fill_in "Compte bancaire numero compte", with: @demande_liquidation.compte_bancaire_numero_compte
    fill_in "Date naissance", with: @demande_liquidation.date_naissance
    fill_in "Etat", with: @demande_liquidation.etat
    fill_in "Lieu naissance", with: @demande_liquidation.lieu_naissance
    fill_in "Mode paiement", with: @demande_liquidation.mode_paiement
    fill_in "Nom", with: @demande_liquidation.nom
    fill_in "Numero affiliation", with: @demande_liquidation.numero_affiliation
    fill_in "Numero dossier", with: @demande_liquidation.numero_dossier
    fill_in "Prenom", with: @demande_liquidation.prenom
    click_on "Create Demande liquidation"

    assert_text "Demande liquidation was successfully created"
    click_on "Back"
  end

  test "updating a Demande liquidation" do
    visit demande_liquidations_url
    click_on "Edit", match: :first

    fill_in "Adresse domicile", with: @demande_liquidation.adresse_domicile
    fill_in "Adresse reception allocation", with: @demande_liquidation.adresse_reception_allocation
    fill_in "Compte bancaire code banque", with: @demande_liquidation.compte_bancaire_code_banque
    fill_in "Compte bancaire code guichet", with: @demande_liquidation.compte_bancaire_code_guichet
    fill_in "Compte bancaire nom banque", with: @demande_liquidation.compte_bancaire_nom_banque
    fill_in "Compte bancaire numero compte", with: @demande_liquidation.compte_bancaire_numero_compte
    fill_in "Date naissance", with: @demande_liquidation.date_naissance
    fill_in "Etat", with: @demande_liquidation.etat
    fill_in "Lieu naissance", with: @demande_liquidation.lieu_naissance
    fill_in "Mode paiement", with: @demande_liquidation.mode_paiement
    fill_in "Nom", with: @demande_liquidation.nom
    fill_in "Numero affiliation", with: @demande_liquidation.numero_affiliation
    fill_in "Numero dossier", with: @demande_liquidation.numero_dossier
    fill_in "Prenom", with: @demande_liquidation.prenom
    click_on "Update Demande liquidation"

    assert_text "Demande liquidation was successfully updated"
    click_on "Back"
  end

  test "destroying a Demande liquidation" do
    visit demande_liquidations_url
    page.accept_confirm do
      click_on "Destroy", match: :first
    end

    assert_text "Demande liquidation was successfully destroyed"
  end
end
