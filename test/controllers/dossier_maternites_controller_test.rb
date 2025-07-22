require 'test_helper'

class DossierMaternitesControllerTest < ActionDispatch::IntegrationTest
  setup do
    @dossier_maternite = dossier_maternites(:one)
  end

  test "should get index" do
    get dossier_maternites_url
    assert_response :success
  end

  test "should get new" do
    get new_dossier_maternite_url
    assert_response :success
  end

  test "should create dossier_maternite" do
    assert_difference('DossierMaternite.count') do
      post dossier_maternites_url, params: { dossier_maternite: { adresse_domicile: @dossier_maternite.adresse_domicile, ajoute_par_id: @dossier_maternite.ajoute_par_id, carriere_valid: @dossier_maternite.carriere_valid, date_naissance: @dossier_maternite.date_naissance, date_soumission: @dossier_maternite.date_soumission, debut_grossesse: @dossier_maternite.debut_grossesse, document_valid: @dossier_maternite.document_valid, etat: @dossier_maternite.etat, etat_civil_demandeur_valid: @dossier_maternite.etat_civil_demandeur_valid, lieu_naissance: @dossier_maternite.lieu_naissance, motif_rejet: @dossier_maternite.motif_rejet, nom: @dossier_maternite.nom, num_affiliation: @dossier_maternite.num_affiliation, num_dossier: @dossier_maternite.num_dossier, prenom: @dossier_maternite.prenom, traite_le: @dossier_maternite.traite_le, traite_par_id: @dossier_maternite.traite_par_id, user_id: @dossier_maternite.user_id } }
    end

    assert_redirected_to dossier_maternite_url(DossierMaternite.last)
  end

  test "should show dossier_maternite" do
    get dossier_maternite_url(@dossier_maternite)
    assert_response :success
  end

  test "should get edit" do
    get edit_dossier_maternite_url(@dossier_maternite)
    assert_response :success
  end

  test "should update dossier_maternite" do
    patch dossier_maternite_url(@dossier_maternite), params: { dossier_maternite: { adresse_domicile: @dossier_maternite.adresse_domicile, ajoute_par_id: @dossier_maternite.ajoute_par_id, carriere_valid: @dossier_maternite.carriere_valid, date_naissance: @dossier_maternite.date_naissance, date_soumission: @dossier_maternite.date_soumission, debut_grossesse: @dossier_maternite.debut_grossesse, document_valid: @dossier_maternite.document_valid, etat: @dossier_maternite.etat, etat_civil_demandeur_valid: @dossier_maternite.etat_civil_demandeur_valid, lieu_naissance: @dossier_maternite.lieu_naissance, motif_rejet: @dossier_maternite.motif_rejet, nom: @dossier_maternite.nom, num_affiliation: @dossier_maternite.num_affiliation, num_dossier: @dossier_maternite.num_dossier, prenom: @dossier_maternite.prenom, traite_le: @dossier_maternite.traite_le, traite_par_id: @dossier_maternite.traite_par_id, user_id: @dossier_maternite.user_id } }
    assert_redirected_to dossier_maternite_url(@dossier_maternite)
  end

  test "should destroy dossier_maternite" do
    assert_difference('DossierMaternite.count', -1) do
      delete dossier_maternite_url(@dossier_maternite)
    end

    assert_redirected_to dossier_maternites_url
  end
end
