require 'test_helper'

class DossierPrestationsControllerTest < ActionDispatch::IntegrationTest
  setup do
    @dossier_prestation = dossier_prestations(:one)
  end

  test "should get index" do
    get dossier_prestations_url
    assert_response :success
  end

  test "should get new" do
    get new_dossier_prestation_url
    assert_response :success
  end

  test "should create dossier_prestation" do
    assert_difference('DossierPrestation.count') do
      post dossier_prestations_url, params: { dossier_prestation: { adresse_domicile: @dossier_prestation.adresse_domicile, carriere_valid: @dossier_prestation.carriere_valid, conjoint_valid: @dossier_prestation.conjoint_valid, date_naissance: @dossier_prestation.date_naissance, date_soumission: @dossier_prestation.date_soumission, date_validation: @dossier_prestation.date_validation, document_valid: @dossier_prestation.document_valid, enfants_valid: @dossier_prestation.enfants_valid, etat: @dossier_prestation.etat, etat_civil_demandeur_valid: @dossier_prestation.etat_civil_demandeur_valid, lieu_naissance: @dossier_prestation.lieu_naissance, nom: @dossier_prestation.nom, num_affiliation: @dossier_prestation.num_affiliation, prenom: @dossier_prestation.prenom, sexe_salarie: @dossier_prestation.sexe_salarie, user_id: @dossier_prestation.user_id, valide_par_id: @dossier_prestation.valide_par_id } }
    end

    assert_redirected_to dossier_prestation_url(DossierPrestation.last)
  end

  test "should show dossier_prestation" do
    get dossier_prestation_url(@dossier_prestation)
    assert_response :success
  end

  test "should get edit" do
    get edit_dossier_prestation_url(@dossier_prestation)
    assert_response :success
  end

  test "should update dossier_prestation" do
    patch dossier_prestation_url(@dossier_prestation), params: { dossier_prestation: { adresse_domicile: @dossier_prestation.adresse_domicile, carriere_valid: @dossier_prestation.carriere_valid, conjoint_valid: @dossier_prestation.conjoint_valid, date_naissance: @dossier_prestation.date_naissance, date_soumission: @dossier_prestation.date_soumission, date_validation: @dossier_prestation.date_validation, document_valid: @dossier_prestation.document_valid, enfants_valid: @dossier_prestation.enfants_valid, etat: @dossier_prestation.etat, etat_civil_demandeur_valid: @dossier_prestation.etat_civil_demandeur_valid, lieu_naissance: @dossier_prestation.lieu_naissance, nom: @dossier_prestation.nom, num_affiliation: @dossier_prestation.num_affiliation, prenom: @dossier_prestation.prenom, sexe_salarie: @dossier_prestation.sexe_salarie, user_id: @dossier_prestation.user_id, valide_par_id: @dossier_prestation.valide_par_id } }
    assert_redirected_to dossier_prestation_url(@dossier_prestation)
  end

  test "should destroy dossier_prestation" do
    assert_difference('DossierPrestation.count', -1) do
      delete dossier_prestation_url(@dossier_prestation)
    end

    assert_redirected_to dossier_prestations_url
  end
end
