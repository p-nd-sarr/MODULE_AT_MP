require 'test_helper'

class DemandeLiquidationsControllerTest < ActionDispatch::IntegrationTest
  setup do
    @demande_liquidation = demande_liquidations(:one)
  end

  test "should get index" do
    get demande_liquidations_url
    assert_response :success
  end

  test "should get new" do
    get new_demande_liquidation_url
    assert_response :success
  end

  test "should create demande_liquidation" do
    assert_difference('DemandeLiquidation.count') do
      post demande_liquidations_url, params: { demande_liquidation: { adresse_domicile: @demande_liquidation.adresse_domicile, adresse_reception_allocation: @demande_liquidation.adresse_reception_allocation, compte_bancaire_code_banque: @demande_liquidation.compte_bancaire_code_banque, compte_bancaire_code_guichet: @demande_liquidation.compte_bancaire_code_guichet, compte_bancaire_nom_banque: @demande_liquidation.compte_bancaire_nom_banque, compte_bancaire_numero_compte: @demande_liquidation.compte_bancaire_numero_compte, date_naissance: @demande_liquidation.date_naissance, etat: @demande_liquidation.etat, lieu_naissance: @demande_liquidation.lieu_naissance, mode_paiement: @demande_liquidation.mode_paiement, nom: @demande_liquidation.nom, numero_affiliation: @demande_liquidation.numero_affiliation, numero_dossier: @demande_liquidation.numero_dossier, prenom: @demande_liquidation.prenom } }
    end

    assert_redirected_to demande_liquidation_url(LiquidationRetraite.last)
  end

  test "should show demande_liquidation" do
    get demande_liquidation_url(@demande_liquidation)
    assert_response :success
  end

  test "should get edit" do
    get edit_demande_liquidation_url(@demande_liquidation)
    assert_response :success
  end

  test "should update demande_liquidation" do
    patch demande_liquidation_url(@demande_liquidation), params: { demande_liquidation: { adresse_domicile: @demande_liquidation.adresse_domicile, adresse_reception_allocation: @demande_liquidation.adresse_reception_allocation, compte_bancaire_code_banque: @demande_liquidation.compte_bancaire_code_banque, compte_bancaire_code_guichet: @demande_liquidation.compte_bancaire_code_guichet, compte_bancaire_nom_banque: @demande_liquidation.compte_bancaire_nom_banque, compte_bancaire_numero_compte: @demande_liquidation.compte_bancaire_numero_compte, date_naissance: @demande_liquidation.date_naissance, etat: @demande_liquidation.etat, lieu_naissance: @demande_liquidation.lieu_naissance, mode_paiement: @demande_liquidation.mode_paiement, nom: @demande_liquidation.nom, numero_affiliation: @demande_liquidation.numero_affiliation, numero_dossier: @demande_liquidation.numero_dossier, prenom: @demande_liquidation.prenom } }
    assert_redirected_to demande_liquidation_url(@demande_liquidation)
  end

  test "should destroy demande_liquidation" do
    assert_difference('DemandeLiquidation.count', -1) do
      delete demande_liquidation_url(@demande_liquidation)
    end

    assert_redirected_to demande_liquidations_url
  end
end
