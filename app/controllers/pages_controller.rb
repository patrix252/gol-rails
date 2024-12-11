class PagesController < ApplicationController
  before_action :authenticate_user!

  def index
  end

  def new
  end

  def upload
    upload = params.require(:anything).permit(:board)
    board = upload[:board]

    if board.present?
      flash[:notice] = "Upload successful"
      @grid_data = parse_file(board.tempfile)
      render :play
    else
      flash[:alert] = "Please upload a board"
      redirect_to new_path
    end
  end

  def play
  end

  private

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
      grid: grid.map { |line| line.chars.map { |cell | cell == "*" } }
    }
  rescue StandardError => e
    Rails.logger.error("File parsing error: #{e.message}")
    nil
  end
end
