require 'test_helper'

class Admin::TypePieceIdentificationsControllerTest < ActionDispatch::IntegrationTest
  setup do
    @admin_type_piece_identification = admin_type_piece_identifications(:one)
  end

  test "should get index" do
    get admin_type_piece_identifications_url
    assert_response :success
  end

  test "should get new" do
    get new_admin_type_piece_identification_url
    assert_response :success
  end

  test "should create admin_type_piece_identification" do
    assert_difference('Admin::TypePieceIdentification.count') do
      post admin_type_piece_identifications_url, params: { admin_type_piece_identification: { code: @admin_type_piece_identification.code, description: @admin_type_piece_identification.description } }
    end

    assert_redirected_to admin_type_piece_identification_url(Admin::TypePieceIdentification.last)
  end

  test "should show admin_type_piece_identification" do
    get admin_type_piece_identification_url(@admin_type_piece_identification)
    assert_response :success
  end

  test "should get edit" do
    get edit_admin_type_piece_identification_url(@admin_type_piece_identification)
    assert_response :success
  end

  test "should update admin_type_piece_identification" do
    patch admin_type_piece_identification_url(@admin_type_piece_identification), params: { admin_type_piece_identification: { code: @admin_type_piece_identification.code, description: @admin_type_piece_identification.description } }
    assert_redirected_to admin_type_piece_identification_url(@admin_type_piece_identification)
  end

  test "should destroy admin_type_piece_identification" do
    assert_difference('Admin::TypePieceIdentification.count', -1) do
      delete admin_type_piece_identification_url(@admin_type_piece_identification)
    end

    assert_redirected_to admin_type_piece_identifications_url
  end
end
