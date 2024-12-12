require "test_helper"

class PagesControllerTest < ActionDispatch::IntegrationTest
  include Devise::Test::IntegrationHelpers

  test "should redirect to login" do
    get root_url
    # assert redirect login
    assert_response :redirect
  end

  test "should get index" do
    sign_in users(:one)
    get root_url
    assert_response :success
  end
end
