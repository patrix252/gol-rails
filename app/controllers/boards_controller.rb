class BoardsController < ApplicationController
  before_action :authenticate_user!
  before_action :set_board, only: %i[ show destroy data ]

  MAX_FUTURE_GENERATIONS = 100

  # GET /boards
  def index
    @boards = Board.all
  end

  # GET /boards/1
  def show
  end

  # GET /boards/new
  def new
    @board = Board.new
  end

  # POST /boards
  def create
    gol = GameOfLife.from_file(board_params[:grid_file].tempfile)
    @board = gol.to_board

    if @board.save
      redirect_to @board, notice: "Board was successfully created."
    else
      render :new, status: :unprocessable_entity
    end

  rescue ArgumentError => e
      @board = Board.new
      @board.errors.add(:grid_file, e.message)
      render :new, status: :unprocessable_entity
  end

  # DELETE /boards/1
  def destroy
    @board.destroy!

    respond_to do |format|
      format.html { redirect_to boards_path, status: :see_other, notice: "Board was successfully destroyed." }
    end
  end

  # GET /boards/1/data
  def data
    generation = params[:generation].present? ? params[:generation].to_i : @board.generation

    # generation less than board generation
    if generation < @board.generation
      head :bad_request
      return
    end

    gol_cache = Rails.cache.read("board_#{@board.id}")

    # generation over the max generation limit
    if (not gol_cache and generation > @board.generation + MAX_FUTURE_GENERATIONS) or
      (gol_cache and gol_cache.generation > gol_cache.generation + MAX_FUTURE_GENERATIONS)
      head :bad_request
      return
    end

    gol = gol_cache && generation > gol_cache.generation ? gol_cache : GameOfLife.new(board: @board)

    while gol.generation < generation
      gol.next_generation
    end

    Rails.cache.write("board_#{@board.id}", gol, expires_in: 1.hour)
    send_data [ gol.board_data ].pack("B*"), type: "application/octet-stream", disposition: "inline"
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
end
