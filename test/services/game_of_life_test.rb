require "test_helper"

class GameOfLifeTest < ActiveSupport::TestCase
  def setup
    @board = Board.new(generation: 0, rows: 4, cols: 4, data: "0100011000100000")
    @game_of_life = GameOfLife.new(board: @board)
  end

  def test_initialize
    assert_equal 0, @game_of_life.generation
    assert_equal 4, @game_of_life.rows
    assert_equal 4, @game_of_life.cols
    assert_equal %w[0100 0110 0010 0000], @game_of_life.grid
  end

  def test_next_generation
    @game_of_life.next_generation
    assert_equal %w[0110 0110 0110 0000], @game_of_life.grid
    assert_equal 1, @game_of_life.generation
  end

  def test_to_s
    assert_equal %w[.*.. .**. ..*. ....].join("\n"), @game_of_life.to_s
  end

  def test_board_data
    assert_equal "0100011000100000", @game_of_life.board_data
  end

  def test_invalid_board
    board = Board.new(generation: 0, rows: 4, cols: 4, data: "010001100010")
    assert_raises(ArgumentError) { GameOfLife.new(board: board) }
  end
end
