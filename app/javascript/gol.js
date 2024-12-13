class GameOfLife {
  CELL_SIZE = 10;

  constructor(canvasId, resetButtonId, startButtonId, stopButtonId, generationFieldId) {
    this.canvas = document.getElementById(canvasId);
    this.boardId = this.canvas.dataset.boardId;
    this.cols = parseInt(this.canvas.dataset.cols);
    this.rows = parseInt(this.canvas.dataset.rows);
    this.generationInit = parseInt(this.canvas.dataset.gen);
    this.generation = parseInt(this.canvas.dataset.gen);
    this.generationField = document.getElementById(generationFieldId);
    this.sessionId = this.canvas.dataset.sessionId;
    this.playInterval = null;

    this.ctx = this.canvas.getContext('2d');

    // Set the canvas width and height based on the grid dimensions and cell size
    this.canvas.width = this.cols * this.CELL_SIZE;
    this.canvas.height = this.rows * this.CELL_SIZE;

    this.resetButton = document.getElementById(resetButtonId);
    this.startButton = document.getElementById(startButtonId);
    this.stopButton = document.getElementById(stopButtonId);

    this.resetButton.addEventListener('click', async () => {
      await this.reset();
    });
    this.startButton.addEventListener('click', () => {
      this.play();
    });
    this.stopButton.addEventListener('click', () => {
      this.stop();
    })

    this.disablePlayButton(false);
    this.disableStopButton(true);

    this.getBoard(this.generation).then(board => {
      this.drawBoard(board);
    }).catch(err => {
      console.error(err);
    })
  }

  play() {
    this.disablePlayButton(true);
    this.disableStopButton(false);

    if (this.playInterval) return;

    this.playInterval = setInterval(async () => {
      await this.drawNextGeneration();
    }, 1000);
  }

  stop() {
    this.disablePlayButton(false);
    this.disableStopButton(true);

    if (this.playInterval) {
      clearInterval(this.playInterval);
      this.playInterval = null;
    }
  }

  async reset() {
    this.stop();

    const board = await this.getBoard(this.generationInit);
    this.drawBoard(board);
    this.updateGeneration(this.generationInit);
  }

  async drawNextGeneration() {
    this.updateGeneration(this.generation + 1);

    const board = await this.getBoard(this.generation);
    this.drawBoard(board);

  }

  disablePlayButton(value) {
    this.startButton.disabled = value;
  }

  disableStopButton(value) {
    this.stopButton.disabled = value;
  }

  updateGeneration(generation) {
    this.generation = generation;
    this.generationField.value = generation;
    this.canvas.dataset.gen = this.generation.toString();
  }

  drawBoard(board) {
    // Loop through the grid and draw each cell
    for (let row = 0; row < this.rows; row++) {
      for (let col = 0; col < this.cols; col++) {
        // Set the fill color to black for true, white for false
        this.ctx.fillStyle = board[row][col] ? 'black' : 'white';

        // Draw the rectangle (cell) at the correct position
        this.ctx.fillRect(col * this.CELL_SIZE, row * this.CELL_SIZE, this.CELL_SIZE, this.CELL_SIZE);

        // draw a border for each cell (e.g., gray border)
        this.ctx.strokeStyle = 'gray';
        this.ctx.strokeRect(col * this.CELL_SIZE, row * this.CELL_SIZE, this.CELL_SIZE, this.CELL_SIZE);
      }
    }
  }

  async getBoard(generation) {

    try {
      const resp = await fetch(`/boards/${this.boardId}/data?${new URLSearchParams(
        {generation: generation, session_id: this.sessionId})}`);

      if (!resp.ok) {
        throw new Error(`Error fetching board data: ${resp.statusText}`);
      }

      const blob = await resp.blob();
      const arrayBuffer = await blob.arrayBuffer();
      const byteArray = new Uint8Array(arrayBuffer);

      const booleanArray = [];
      let row = [];

      byteArray.forEach(byte => {
        for (let i = 7; i >= 0; i--) {
          const bit = (byte >> i) & 1;
          row.push(bit === 1);

          if (row.length === this.cols) {
            booleanArray.push(row);
            row = [];
          }
        }
      });

      if (row.length > 0) booleanArray.push(row);

      return booleanArray;
    } catch (error) {
      console.error(error);
      throw error;
    }
  }
}

document.addEventListener("DOMContentLoaded", async (event) => {
  new GameOfLife('board', 'btn-reset', 'btn-start', 'btn-stop', 'generation');
});
