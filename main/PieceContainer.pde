import java.util.*;


/*
*  !!!! TERRIBLE CODE WARNING !!!!
*/


class PieceContainer {
  
  private final int X_OFFSET = 10;
  private final int Y_OFFSET = 20;
  
  private int x,y,w,h;
  private TreeMap<Integer, PuzzlePiece> pieces = new TreeMap<Integer, PuzzlePiece>();
  private HashMap<PuzzlePiece, Integer> pieceOffsets = new HashMap<PuzzlePiece, Integer>();
  
  private int sliderY, sliderX, sliderHeight;
  private int nextYPos;
  
  private color colorScheme;
  
  public PieceContainer(int x, int y, int w, int h, color colorScheme){
    this.x = x;
    this.y = y;
    this.w = w;
    this.h = h;
    this.colorScheme = colorScheme;
    sliderY = y;
    sliderX = x+w-X_OFFSET;
    sliderHeight = 0;
    nextYPos = y+Y_OFFSET;
  }
  
  public void addPuzzlePiece(PuzzlePiece piece) {
    float shrinkWidth = piece.getWidth();
    float shrinkHeight = piece.getHeight();
    if (piece.getWidth() > this.w){
      shrinkWidth = map(piece.getWidth(), 0, w*2, 0, this.w-X_OFFSET);
      shrinkHeight = map(piece.getHeight(), 0, this.w*2, 0, this.w-Y_OFFSET);
    }
    piece.setShrinkSize((int) shrinkWidth, (int) shrinkHeight);
    piece.shrink();
    piece.moveTo(x+X_OFFSET, nextYPos);
    pieces.put(piece.getID(), piece);
    pieceOffsets.put(piece, nextYPos);
    nextYPos += piece.getHeight() + Y_OFFSET;
    sliderHeight = (int) (h / ((nextYPos/((double)h))));
  }
  
  public void removePuzzlePiece(PuzzlePiece piece){
    pieceOffsets.remove(piece);
    pieces.remove(piece.getID());
    sliderY = y;
    nextYPos = y + Y_OFFSET;
    for (PuzzlePiece pp : pieces.values()) {
      pp.moveTo(x+X_OFFSET, nextYPos);
      pieceOffsets.put(pp, nextYPos);
      nextYPos += pp.getHeight() + Y_OFFSET;
    }
    println(nextYPos);
    sliderHeight = (int) (h / ((nextYPos/((double)h))));
    println(sliderHeight);
  }
  
  public void render(){
    if (mousePressed){
      if (mouseX > x && mouseX < x+w && mouseY > y && mouseY < y+h){
          sliderY = constrain(mouseY-sliderHeight/2, y, y+h-sliderHeight);
      }
    }
    
    // Container border
    strokeWeight(4);
    stroke(colorScheme);
    rect(x,y,w,h);
    noStroke();
    
    for (PuzzlePiece pp : pieces.values()) {
      pp.moveTo(pp.getX(), pieceOffsets.get(pp)+(y-sliderY));
      if (pp.getY() > y && pp.getY() + pp.getHeight() < y+h){
        pp.show();
      }
    }
    
    // Slider
    fill(colorScheme);
    sliderHeight = sliderHeight > h ? h : sliderHeight;
    rect(sliderX, sliderY, X_OFFSET, sliderHeight);
  }
  
  public PuzzlePiece getPiece(int x, int y){
    if (x > this.x && x < this.x + this.w)
      if (y > this.y && y < this.y + this.h)
        for (PuzzlePiece pp : pieces.values()) {
          if (pp.containsMouse(x,y))
            return pp;
        }
    return null;
  }
}
