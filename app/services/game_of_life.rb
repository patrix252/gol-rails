class GameOfLife
  attr_reader :generation, :rows, :cols, :grid

  def initialize(board: Board)
    raise ArgumentError, "Invalid board. #{board.errors.full_messages}" unless board.is_a?(Board) && board.valid?
    @generation = board.generation
    @rows = board.rows
    @cols = board.cols
    @grid = board.data.chars.each_slice(cols).map(&:join)
  end

  def next_generation
    new_grid = Array.new(rows) { Array.new(cols, "0") }

    rows.times do |r|
      cols.times do |c|
        live_neighbors = count_live_neighbors(r, c)
        if grid[r][c] == "1"
          new_grid[r][c] = (live_neighbors == 2 || live_neighbors == 3) ? "1" : "0"
        else
          new_grid[r][c] = live_neighbors == 3 ? "1" : "0"
        end
      end
    end

    @grid = new_grid.map(&:join)
    @generation += 1
  end

  def to_s
    @grid.join("\n").gsub("1", "*").gsub("0", ".")
  end

  def to_board
    Board.new(generation: generation, rows: rows, cols: cols, data: board_data)
  end

  def board_data
    grid.flatten.map { |row | row.gsub("*", "1").gsub(".", "0") }.join
  end

  # create static method to create a new game of life from a file
  def self.from_file(file_path)
    if file_path.nil? || !File.exist?(file_path)
      raise ArgumentError, "Invalid file path"
    end

    begin
      content = File.read(file_path).lines.map(&:strip)
    rescue Exception
      raise ArgumentError, "Invalid file format"
    end

    unless content.size >= 3
      raise ArgumentError, "Invalid file format: must have at least 3 lines"
    end

    unless content.first.strip.match?(/^Generation \d+:$/)
      raise ArgumentError, "Invalid file format: first line must be 'Generation <number>:'"
    end

    unless content[1].strip.match?(/^\d+ \d+$/)
      raise ArgumentError, "Invalid file format: second line must be '<rows> <cols>'"
    end

    generation = content.first.split.last.to_i
    rows, cols = content[1].split.map(&:to_i)

    grid = content[2..-1]
    unless grid.size == rows && grid.all? { |line| line.length == cols }
      raise ArgumentError, "Invalid file format: grid size does not match dimensions"
    end

    # check characters different from '*' and '.'
    unless grid.all? { |line| line.match?(/^[*.]+$/) }
      raise ArgumentError, "Invalid file format: grid must contain only '*' and '.' characters"
    end

    data = grid.flatten.map { |row | row.gsub("*", "1").gsub(".", "0") }.join

    board = Board.new(generation: generation, rows: rows, cols: cols, data: data)
    new(board: board)
  end

  private

  def count_live_neighbors(row, col)
    directions = [ -1, 0, 1 ].repeated_permutation(2).to_a - [ [ 0, 0 ] ]
    directions.count do |dr, dc|
      r, c = row + dr, col + dc
      r.between?(0, rows - 1) && c.between?(0, cols - 1) && grid[r][c] == "1"
    end
  end
end
