require 'test_helper'

class Salarie::ConjointsControllerTest < ActionDispatch::IntegrationTest
  setup do
    @salarie_conjoint = salarie_conjoints(:one)
  end

  test "should get index" do
    get salarie_conjoints_url
    assert_response :success
  end

  test "should get new" do
    get new_salarie_conjoint_url
    assert_response :success
  end

  test "should create salarie_conjoint" do
    assert_difference('Salarie::Conjoint.count') do
      post salarie_conjoints_url, params: { salarie_conjoint: { date_mariage: @salarie_conjoint.date_mariage, date_naissance: @salarie_conjoint.date_naissance, nin: @salarie_conjoint.nin, nom: @salarie_conjoint.nom, prenom: @salarie_conjoint.prenom, user_id: @salarie_conjoint.user_id } }
    end

    assert_redirected_to salarie_conjoint_url(Salarie::Conjoint.last)
  end

  test "should show salarie_conjoint" do
    get salarie_conjoint_url(@salarie_conjoint)
    assert_response :success
  end

  test "should get edit" do
    get edit_salarie_conjoint_url(@salarie_conjoint)
    assert_response :success
  end

  test "should update salarie_conjoint" do
    patch salarie_conjoint_url(@salarie_conjoint), params: { salarie_conjoint: { date_mariage: @salarie_conjoint.date_mariage, date_naissance: @salarie_conjoint.date_naissance, nin: @salarie_conjoint.nin, nom: @salarie_conjoint.nom, prenom: @salarie_conjoint.prenom, user_id: @salarie_conjoint.user_id } }
    assert_redirected_to salarie_conjoint_url(@salarie_conjoint)
  end

  test "should destroy salarie_conjoint" do
    assert_difference('Salarie::Conjoint.count', -1) do
      delete salarie_conjoint_url(@salarie_conjoint)
    end

    assert_redirected_to salarie_conjoints_url
  end
end
