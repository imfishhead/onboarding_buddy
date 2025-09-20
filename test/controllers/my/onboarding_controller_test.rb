require "test_helper"

class My::OnboardingControllerTest < ActionDispatch::IntegrationTest
  test "should get index" do
    get my_onboarding_index_url
    assert_response :success
  end

  test "should get complete" do
    get my_onboarding_complete_url
    assert_response :success
  end
end
