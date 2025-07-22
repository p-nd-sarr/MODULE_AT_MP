require 'test_helper'

class Admin::ConventionCollectivesControllerTest < ActionDispatch::IntegrationTest
  setup do
    @admin_convention_collective = admin_convention_collectives(:one)
  end

  test "should get index" do
    get admin_convention_collectives_url
    assert_response :success
  end

  test "should get new" do
    get new_admin_convention_collective_url
    assert_response :success
  end

  test "should create admin_convention_collective" do
    assert_difference('Admin::ConventionCollective.count') do
      post admin_convention_collectives_url, params: { admin_convention_collective: { code: @admin_convention_collective.code, description: @admin_convention_collective.description } }
    end

    assert_redirected_to admin_convention_collective_url(Admin::ConventionCollective.last)
  end

  test "should show admin_convention_collective" do
    get admin_convention_collective_url(@admin_convention_collective)
    assert_response :success
  end

  test "should get edit" do
    get edit_admin_convention_collective_url(@admin_convention_collective)
    assert_response :success
  end

  test "should update admin_convention_collective" do
    patch admin_convention_collective_url(@admin_convention_collective), params: { admin_convention_collective: { code: @admin_convention_collective.code, description: @admin_convention_collective.description } }
    assert_redirected_to admin_convention_collective_url(@admin_convention_collective)
  end

  test "should destroy admin_convention_collective" do
    assert_difference('Admin::ConventionCollective.count', -1) do
      delete admin_convention_collective_url(@admin_convention_collective)
    end

    assert_redirected_to admin_convention_collectives_url
  end
end
