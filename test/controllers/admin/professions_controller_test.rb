require 'test_helper'

class Admin::ProfessionsControllerTest < ActionDispatch::IntegrationTest
  setup do
    @admin_profession = admin_professions(:one)
  end

  test "should get index" do
    get admin_professions_url
    assert_response :success
  end

  test "should get new" do
    get new_admin_profession_url
    assert_response :success
  end

  test "should create admin_profession" do
    assert_difference('Admin::Profession.count') do
      post admin_professions_url, params: { admin_profession: { code: @admin_profession.code, description: @admin_profession.description } }
    end

    assert_redirected_to admin_profession_url(Admin::Profession.last)
  end

  test "should show admin_profession" do
    get admin_profession_url(@admin_profession)
    assert_response :success
  end

  test "should get edit" do
    get edit_admin_profession_url(@admin_profession)
    assert_response :success
  end

  test "should update admin_profession" do
    patch admin_profession_url(@admin_profession), params: { admin_profession: { code: @admin_profession.code, description: @admin_profession.description } }
    assert_redirected_to admin_profession_url(@admin_profession)
  end

  test "should destroy admin_profession" do
    assert_difference('Admin::Profession.count', -1) do
      delete admin_profession_url(@admin_profession)
    end

    assert_redirected_to admin_professions_url
  end
end
