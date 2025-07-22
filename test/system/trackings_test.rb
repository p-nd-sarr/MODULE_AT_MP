require "application_system_test_case"

class TrackingsTest < ApplicationSystemTestCase
  setup do
    @tracking = trackings(:one)
  end

  test "visiting the index" do
    visit trackings_url
    assert_selector "h1", text: "Trackings"
  end

  test "creating a Tracking" do
    visit trackings_url
    click_on "New Tracking"

    fill_in "Action", with: @tracking.action
    fill_in "Contenu", with: @tracking.contenu
    fill_in "Controller", with: @tracking.controller
    fill_in "Ip", with: @tracking.ip
    fill_in "Path", with: @tracking.path
    fill_in "Path source", with: @tracking.path_source
    fill_in "Type requete", with: @tracking.type_requete
    fill_in "User", with: @tracking.user_id
    click_on "Create Tracking"

    assert_text "Tracking was successfully created"
    click_on "Back"
  end

  test "updating a Tracking" do
    visit trackings_url
    click_on "Edit", match: :first

    fill_in "Action", with: @tracking.action
    fill_in "Contenu", with: @tracking.contenu
    fill_in "Controller", with: @tracking.controller
    fill_in "Ip", with: @tracking.ip
    fill_in "Path", with: @tracking.path
    fill_in "Path source", with: @tracking.path_source
    fill_in "Type requete", with: @tracking.type_requete
    fill_in "User", with: @tracking.user_id
    click_on "Update Tracking"

    assert_text "Tracking was successfully updated"
    click_on "Back"
  end

  test "destroying a Tracking" do
    visit trackings_url
    page.accept_confirm do
      click_on "Destroy", match: :first
    end

    assert_text "Tracking was successfully destroyed"
  end
end
