require "test_helper"

class BoardsControllerTest < ActionDispatch::IntegrationTest
  include Devise::Test::IntegrationHelpers

  setup do
    sign_in users(:one)
    @board = boards(:one)
  end

  test "should get index" do
    get boards_url
    assert_response :success
  end

  test "should get new" do
    get new_board_url
    assert_response :success
  end

  test "should create board" do
    assert_difference("Board.count") do
      post boards_url, params: { board: { grid_file: fixture_file_upload("board_right.txt", "text/plain") } }
    end

    assert_redirected_to board_url(Board.last)
  end

  test "should not create board with invalid file" do
    assert_no_difference("Board.count") do
      post boards_url, params: { board: { grid_file: fixture_file_upload("board_wrong_gen.txt", "text/plain") } }
    end
    assert_response :unprocessable_entity

    assert_no_difference("Board.count") do
      post boards_url, params: { board: { grid_file: fixture_file_upload("board_wrong_col.txt", "text/plain") } }
    end
    assert_response :unprocessable_entity

    assert_no_difference("Board.count") do
      post boards_url, params: { board: { grid_file: fixture_file_upload("board_wrong_col2.txt", "text/plain") } }
    end
    assert_response :unprocessable_entity

    assert_no_difference("Board.count") do
      post boards_url, params: { board: { grid_file: fixture_file_upload("board_wrong_grid.txt", "text/plain") } }
    end
    assert_response :unprocessable_entity

    assert_no_difference("Board.count") do
      post boards_url, params: { board: { grid_file: fixture_file_upload("board_wrong_grid2.txt", "text/plain") } }
    end
    assert_response :unprocessable_entity

    assert_no_difference("Board.count") do
      post boards_url, params: { board: { grid_file: fixture_file_upload("board_wrong_grid3.txt", "text/plain") } }
    end
    assert_response :unprocessable_entity
  end

  test "should show board" do
    get board_url(@board)
    assert_response :success
  end

  test "should destroy board" do
    assert_difference("Board.count", -1) do
      delete board_url(@board)
    end

    assert_redirected_to boards_url
  end

  test "should get data" do
    get data_board_url(@board, params: { session_id: SecureRandom.uuid })
    assert_response :success
    assert_equal "application/octet-stream", response.content_type
    assert_equal @board.data, response.body.unpack("B*").first

    # check valid session_id
    get data_board_url(@board, params: { session_id: SecureRandom.uuid })
    assert_response :success

    get data_board_url(@board, params: {})
    assert_response :bad_request

    # test next generation
    get data_board_url(@board, params: { generation: @board.generation + 1, session_id: SecureRandom.uuid })
    assert_response :success

    # test with generation less than board generation
    get data_board_url(@board, params: { generation: 0, session_id: SecureRandom.uuid })
    assert_response :bad_request

    # test with generation equal to board generation
    get data_board_url(@board, params: { generation: @board.generation, session_id: SecureRandom.uuid })
    assert_response :success

    # test with generation over the max generation limit
    get data_board_url(@board, params: { generation: @board.generation + 150, session_id: SecureRandom.uuid })
    assert_response :bad_request
  end
end
