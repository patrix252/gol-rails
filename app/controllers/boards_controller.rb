class BoardsController < ApplicationController
  before_action :set_board, only: %i[ show destroy ]

  # GET /boards or /boards.json
  def index
    @boards = Board.all
  end

  # GET /boards/1 or /boards/1.json
  def show
  end

  # GET /boards/new
  def new
    @board = Board.new
  end

  # POST /boards or /boards.json
  def create
    data = parse_file(board_params[:grid_file].tempfile)

    puts data[:grid]

    @board = Board.new(
      generation: data[:generation],
      rows: data[:rows],
      cols: data[:cols],
      data: data[:grid],
      user: current_user
      )

    respond_to do |format|
      if @board.save
        format.html { redirect_to @board, notice: "Board was successfully created." }
        format.json { render :show, status: :created, location: @board }
      else
        format.html { render :new, status: :unprocessable_entity }
        format.json { render json: @board.errors, status: :unprocessable_entity }
      end
    end
  end

  # DELETE /boards/1 or /boards/1.json
  def destroy
    @board.destroy!

    respond_to do |format|
      format.html { redirect_to boards_path, status: :see_other, notice: "Board was successfully destroyed." }
      format.json { head :no_content }
    end
  end

  private

  # Use callbacks to share common setup or constraints between actions.
  def set_board
    @board = Board.find(params.expect(:id))
  end

  # Only allow a list of trusted parameters through.
  def board_params
    params.expect(board: [ :grid_file ])
  end

  def parse_file(file_path)
    content = File.read(file_path).lines.map(&:strip)
    # Validate format
    return unless content.first.match?(/^Generation \d+:$/)
    return unless content[1].match?(/^\d+ \d+$/)

    generation = content.first.split.last.to_i
    dimensions = content[1].split.map(&:to_i)
    rows, cols = dimensions

    grid = content[2..-1] # Get grid rows
    return unless grid.size == rows && grid.all? { |line| line.length == cols }

    {
      generation: generation,
      rows: rows,
      cols: cols,
      grid: grid.flatten.map { |row | row.gsub("*", "1").gsub(".", "0") }.join
    }
  rescue StandardError => e
    Rails.logger.error("File parsing error: #{e.message}")
    nil
  end
end
