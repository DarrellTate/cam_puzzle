class PuzzlePiece extends CImage {
  
  // Returns the ID of this puzzle piece.
  // Utilized by SnapPoint to determine if this piece is in the right spot
  public int getID(){
    return PIECE_ID;
  }
  
  // True if there are more than 20 pixels in a puzzle piece.
  // Utilized by the Puzzle class to determine if the piece should be remembered
  public boolean isValidPuzzlePiece(){
    return pixelMap.size() >= 20;
  }
  
  // Overriding from CImage class
  public void moveTo(int x, int y){
    super.moveTo(x,y);
    glitchPiece();
  }
  
  //TODO: PUT PIECE GLITCH CODE HERE
  private void glitchPiece(){
    // Only methods you should need
    // this.setPixel(pixelIndex, pixelColor) < Same to PImage.pixels[index] = color >
    // this.updatePixels()                   < Same to PImage.updatePixels()>
  }
      
  /*
  * =========================================================
  * Everything below this line is not used in any other class
  * so no need to worry about it.
  *
  * Enter at your own expense.
  * =========================================================
  */
  private final int PIECE_ID;
  private Puzzle puzzle;
  private HashMap<Integer, Integer> pixelMap;
  private int minX, minY, maxX, maxY;
  
  PuzzlePiece(Puzzle puzzle, int pieceID){
    this.puzzle = puzzle;
    this.PIECE_ID = pieceID;
    pixelMap = new HashMap<Integer, Integer>();
    
    minX = puzzle.getWidth()+1;
    minY = puzzle.getHeight()+1;
    maxX = -1;
    maxY = -1;
  }
  
  // Takes the pixel index from the template image and the color at that index
  public void addPixel(int i, color c) {
    pixelMap.put(i,c);
    int x = i%puzzle.getWidth();
    int y = i/puzzle.getHeight();
    
    // Finding the range of the piece. Used for converting to a CImage
    minX = x < minX ? x : minX;
    minY = y < minY ? y : minY;
    maxX = x > maxX ? x : maxX;
    maxY = y > maxY ? y : maxY;
  }
  
  // Converts the HashMap of pixels and their colors into a CImage
  public PuzzlePiece convertToCImage(){    
    int w = maxX-minX;
    int h = maxY-minY;
    int originalImageIndex = 0;
    PImage pieceImg = createImage(w,h,ARGB); // This is the image that will be used to represent the piece
    for (int x = 0; x < w; x++){
      for (int y = 0; y < h; y++){
        originalImageIndex = (y+minY)*puzzle.getWidth()+(x+minX);
        if (pixelMap.containsKey(originalImageIndex))
          pieceImg.pixels[y*w+x] = pixelMap.get(originalImageIndex); // Use pixel specified by addPixel
        else
          pieceImg.pixels[y*w+x] = color(0,0,0,0); // Pixels not specified by addPixel will be transparent
      }
    }
    super.setImage(minX+puzzle.getX(), minY+puzzle.getY(), pieceImg);
    //super.show(); // Display the newly created piece
    return this;
  }
}
