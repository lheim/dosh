require 'test_helper'

class UsrpControllerTest < ActionController::TestCase
  test "should get index" do
    get :index
    assert_response :success
  end

end
