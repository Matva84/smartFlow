require "test_helper"

class MaterialsControllerTest < ActionDispatch::IntegrationTest
  test "should get new" do
    get materials_new_url
    assert_response :success
  end

  test "should get create" do
    get materials_create_url
    assert_response :success
  end

  test "should get edit" do
    get materials_edit_url
    assert_response :success
  end

  test "should get update" do
    get materials_update_url
    assert_response :success
  end

  test "should get destroy" do
    get materials_destroy_url
    assert_response :success
  end
end
