require "test_helper"

class BoardTest < ActiveSupport::TestCase
  def setup
    @board = Board.new(generation: 1, rows: 4, cols: 4, data: "0000111100001111")
  end

  test "should be valid with valid attributes" do
    assert @board.valid?
  end

  test "should be invalid without generation" do
    @board.generation = nil
    assert_not @board.valid?
    assert_includes @board.errors[:generation], "can't be blank"
  end

  test "should be invalid without data" do
    @board.data = nil
    assert_not @board.valid?
    assert_includes @board.errors[:data], "can't be blank"
  end

  test "should be invalid with non-integer generation" do
    @board.generation = "one"
    assert_not @board.valid?
    assert_includes @board.errors[:generation], "is not a number"
  end

  test "should be invalid with negative generation" do
    @board.generation = -1
    assert_not @board.valid?
    assert_includes @board.errors[:generation], "must be greater than or equal to 0"
  end

  test "should be invalid with non-integer rows" do
    @board.rows = "four"
    assert_not @board.valid?
    assert_includes @board.errors[:rows], "is not a number"
  end

  test "should be invalid with rows less than or equal to 0" do
    @board.rows = 0
    assert_not @board.valid?
    assert_includes @board.errors[:rows], "must be greater than 0"
  end

  test "should be invalid with rows greater than 100" do
    @board.rows = 101
    assert_not @board.valid?
    assert_includes @board.errors[:rows], "must be less than or equal to 100"
  end

  test "should be invalid with non-integer cols" do
    @board.cols = "four"
    assert_not @board.valid?
    assert_includes @board.errors[:cols], "is not a number"
  end

  test "should be invalid with cols less than or equal to 0" do
    @board.cols = 0
    assert_not @board.valid?
    assert_includes @board.errors[:cols], "must be greater than 0"
  end

  test "should be invalid with cols greater than 100" do
    @board.cols = 101
    assert_not @board.valid?
    assert_includes @board.errors[:cols], "must be less than or equal to 100"
  end

  test "should be invalid if data length does not match dimensions" do
    @board.data = "0000"
    assert_not @board.valid?
    assert_includes @board.errors[:data], "length must be equal to rows * cols"
  end
end
