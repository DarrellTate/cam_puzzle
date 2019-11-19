import java.util.*;


/*
*  !!!! TERRIBLE CODE WARNING !!!!
*
* Nothing below this line should be need so enter at your own risk
*/


class PieceContainer {
  
  private final int SLIDER_WIDTH = 15;
  private final int X_OFFSET = 10;
  private final int Y_OFFSET = 20;
  private color foreground, background;
  private PuzzlePiece activePiece;
  
  private int x,y,w,h;
  private HashMap<Integer, PuzzlePiece> pieces = new HashMap<Integer, PuzzlePiece>();
  private HashMap<PuzzlePiece, Integer> pieceOffsets = new HashMap<PuzzlePiece, Integer>();
  
  private int sliderY, sliderX, sliderHeight;
  private int nextYPos;
  private int maxPieceWidth = -1;
  
  public PieceContainer(int x, int y, int w, int h){
    this.x = x;
    this.y = y;
    this.w = w;
    this.h = h;
    
    foreground = 0x0;  // Black
    background = 0x0;  // Black
    
    sliderY = y;
    sliderX = x+w-SLIDER_WIDTH;
    sliderHeight = 0;
    nextYPos = y+Y_OFFSET;
  }
  
  public void setColorScheme(color foreground, color background){
    this.foreground = foreground;
    this.background = background;
  }
  
  public void addPuzzlePiece(PuzzlePiece piece) {
    pieces.put(piece.getID(), piece);
    pieceOffsets.put(piece, nextYPos);
    
    // Calculating new piece size
    maxPieceWidth = piece.getWidth() > maxPieceWidth ? piece.getWidth() : maxPieceWidth;
    float shrinkWidth = map(piece.getWidth(), 0, maxPieceWidth, 0, this.w - SLIDER_WIDTH - (X_OFFSET<<1));
    float shrinkHeight = map(piece.getHeight(), 0, maxPieceWidth, 0, this.w);
    
    // Shrinking piece based on new size
    piece.setShrinkSize((int) shrinkWidth, (int) shrinkHeight);
    piece.shrink();
    
    // Move piece to correct sport in the container
    piece.moveTo(x+X_OFFSET, nextYPos);
    nextYPos += piece.getHeight() + Y_OFFSET;
    // Change the slider size in order to see all pieces
    sliderHeight = (int) (h/((nextYPos/((double)(y+h)))));
    render();
  }
  
  public void removePuzzlePiece(PuzzlePiece piece){
    activePiece = null;
    // Removing the desired piece from the piece container
    pieceOffsets.remove(piece);
    pieces.remove(piece.getID());
    
    // Moving all the pieces up so they always stay at top of container
    sliderY = y;
    nextYPos = y + Y_OFFSET;
    for (PuzzlePiece pp : pieces.values()) {
      pp.moveTo(x+X_OFFSET, nextYPos);
      pieceOffsets.put(pp, nextYPos);
      nextYPos += pp.getHeight() + Y_OFFSET;
    }
    
    // Change the slider size in order to see all pieces
    sliderHeight = (int) (h/((nextYPos/((double)(y+h)))));
    
    render();
  }
  
  public void render(){
    if (mousePressed){
      if (mouseX > x && mouseX < x+w && mouseY > y && mouseY < y+h){
          sliderY = constrain(mouseY-sliderHeight/2, y, y+h-sliderHeight);
      }
    }
    
    // Container
    strokeWeight(4);
    stroke(foreground);
    fill(background);
    rect(x,y,w,h);
    noStroke();
    
    for (PuzzlePiece pp : pieces.values()) {
      if (pp != activePiece){
        pp.moveTo(pp.getX(), pieceOffsets.get(pp)+((y-sliderY)*(h/sliderHeight)));
        if (pp.getY() >= y && pp.getY() + pp.getHeight() <= y+h){
          pp.show();
        }
      }
    }
    
    // Slider
    fill(foreground);
    sliderHeight = sliderHeight > h ? h : sliderHeight;
    rect(sliderX, sliderY, SLIDER_WIDTH, sliderHeight);
    stroke(foreground);
    line(sliderX, y+1, sliderX, y+h-1);
  }
  
  public PuzzlePiece getPiece(int x, int y){
    if (x > this.x && x < this.x + this.w)
      if (y > this.y && y < this.y + this.h)
        for (PuzzlePiece pp : pieces.values()) {
          if (pp.containsMouse(x,y)){
            activePiece = pp;
            return pp;
          }
        }
    return null;
  }
}
