private final String image = "resources/puzzle1.jpg";
private Puzzle puzzle;

void setup(){
  size(1000,800);
  puzzle = new Puzzle(new CImage(0,0,image), color(41,230,118), 0x0);
  puzzle.scramble();
  
  /*
   Info regarding the previous 2 lines
  
  new Puzzle(new CImage(int x, int y, <int width>, <int height>, puzzle piece tempate, foreground color, background color)
                                      // <width> and <height> are optional parameters
      // Foreground the the border around the puzzle
      // Background is the color behind the puzzle pieces
      
  puzzle.scramble - Move the pieces to the right side container holding unplaced pieces
  */
}

void draw(){
  surface.setTitle("Frame: " + frameRate);
  puzzle.render(); // Redraws the board
}

void mousePressed() {
  puzzle.selectPiece(mouseX, mouseY);
}

void mouseReleased() {
  puzzle.deselectPiece();
  if (puzzle.isComplete()) // Returns true if the puzzle is correctly solved
    println("Puzzle Is Solved");
}
