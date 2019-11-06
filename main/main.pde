private final String image = "resources/puzzle1.jpg";
private Puzzle puzzle;

void setup(){
  size(800,799);
  puzzle = new Puzzle(new CImage(0,0,image));
}

void draw(){
  surface.setTitle("Frame: " + frameRate);
  puzzle.render(0);
}

void mousePressed() {
  puzzle.selectPiece(mouseX, mouseY);
}

void mouseReleased() {
  puzzle.deselectPiece();
}
