require 'test_helper'

class IndemniteCongesMaternitesControllerTest < ActionDispatch::IntegrationTest
  setup do
    @indemnite_conges_maternite = indemnite_conges_maternites(:one)
  end

  test "should get index" do
    get indemnite_conges_maternites_url
    assert_response :success
  end

  test "should get new" do
    get new_indemnite_conges_maternite_url
    assert_response :success
  end

  test "should create indemnite_conges_maternite" do
    assert_difference('IndemniteCongesMaternite.count') do
      post indemnite_conges_maternites_url, params: { indemnite_conges_maternite: { ajoute_par_id: @indemnite_conges_maternite.ajoute_par_id, date_accouchement: @indemnite_conges_maternite.date_accouchement, date_reprise_service: @indemnite_conges_maternite.date_reprise_service, date_soumission: @indemnite_conges_maternite.date_soumission, date_validation: @indemnite_conges_maternite.date_validation, debut_conges: @indemnite_conges_maternite.debut_conges, debut_grossesse: @indemnite_conges_maternite.debut_grossesse, dossier_prestation_id: @indemnite_conges_maternite.dossier_prestation_id, etat: @indemnite_conges_maternite.etat, montant_paiement: @indemnite_conges_maternite.montant_paiement, motif_rejet: @indemnite_conges_maternite.motif_rejet, paiement: @indemnite_conges_maternite.paiement, traite_le: @indemnite_conges_maternite.traite_le, traite_par_id: @indemnite_conges_maternite.traite_par_id, tranche_paiement: @indemnite_conges_maternite.tranche_paiement, user_id: @indemnite_conges_maternite.user_id, valide_par_id: @indemnite_conges_maternite.valide_par_id } }
    end

    assert_redirected_to indemnite_conges_maternite_url(IndemniteCongesMaternite.last)
  end

  test "should show indemnite_conges_maternite" do
    get indemnite_conges_maternite_url(@indemnite_conges_maternite)
    assert_response :success
  end

  test "should get edit" do
    get edit_indemnite_conges_maternite_url(@indemnite_conges_maternite)
    assert_response :success
  end

  test "should update indemnite_conges_maternite" do
    patch indemnite_conges_maternite_url(@indemnite_conges_maternite), params: { indemnite_conges_maternite: { ajoute_par_id: @indemnite_conges_maternite.ajoute_par_id, date_accouchement: @indemnite_conges_maternite.date_accouchement, date_reprise_service: @indemnite_conges_maternite.date_reprise_service, date_soumission: @indemnite_conges_maternite.date_soumission, date_validation: @indemnite_conges_maternite.date_validation, debut_conges: @indemnite_conges_maternite.debut_conges, debut_grossesse: @indemnite_conges_maternite.debut_grossesse, dossier_prestation_id: @indemnite_conges_maternite.dossier_prestation_id, etat: @indemnite_conges_maternite.etat, montant_paiement: @indemnite_conges_maternite.montant_paiement, motif_rejet: @indemnite_conges_maternite.motif_rejet, paiement: @indemnite_conges_maternite.paiement, traite_le: @indemnite_conges_maternite.traite_le, traite_par_id: @indemnite_conges_maternite.traite_par_id, tranche_paiement: @indemnite_conges_maternite.tranche_paiement, user_id: @indemnite_conges_maternite.user_id, valide_par_id: @indemnite_conges_maternite.valide_par_id } }
    assert_redirected_to indemnite_conges_maternite_url(@indemnite_conges_maternite)
  end

  test "should destroy indemnite_conges_maternite" do
    assert_difference('IndemniteCongesMaternite.count', -1) do
      delete indemnite_conges_maternite_url(@indemnite_conges_maternite)
    end

    assert_redirected_to indemnite_conges_maternites_url
  end
end
