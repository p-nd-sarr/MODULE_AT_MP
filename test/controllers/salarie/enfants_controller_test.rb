require 'test_helper'

class Salarie::EnfantsControllerTest < ActionDispatch::IntegrationTest
  setup do
    @salarie_enfant = salarie_enfants(:one)
  end

  test "should get index" do
    get salarie_enfants_url
    assert_response :success
  end

  test "should get new" do
    get new_salarie_enfant_url
    assert_response :success
  end

  test "should create salarie_enfant" do
    assert_difference('Salarie::Enfant.count') do
      post salarie_enfants_url, params: { salarie_enfant: { date_naissance: @salarie_enfant.date_naissance, nom: @salarie_enfant.nom, nom_mere: @salarie_enfant.nom_mere, nom_pere: @salarie_enfant.nom_pere, prenom: @salarie_enfant.prenom, prenom_mere: @salarie_enfant.prenom_mere, prenom_pere: @salarie_enfant.prenom_pere } }
    end

    assert_redirected_to salarie_enfant_url(Salarie::Enfant.last)
  end

  test "should show salarie_enfant" do
    get salarie_enfant_url(@salarie_enfant)
    assert_response :success
  end

  test "should get edit" do
    get edit_salarie_enfant_url(@salarie_enfant)
    assert_response :success
  end

  test "should update salarie_enfant" do
    patch salarie_enfant_url(@salarie_enfant), params: { salarie_enfant: { date_naissance: @salarie_enfant.date_naissance, nom: @salarie_enfant.nom, nom_mere: @salarie_enfant.nom_mere, nom_pere: @salarie_enfant.nom_pere, prenom: @salarie_enfant.prenom, prenom_mere: @salarie_enfant.prenom_mere, prenom_pere: @salarie_enfant.prenom_pere } }
    assert_redirected_to salarie_enfant_url(@salarie_enfant)
  end

  test "should destroy salarie_enfant" do
    assert_difference('Salarie::Enfant.count', -1) do
      delete salarie_enfant_url(@salarie_enfant)
    end

    assert_redirected_to salarie_enfants_url
  end
end
