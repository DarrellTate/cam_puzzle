/*
* Class represents a puzzle. The puzzle is composed of an image, which is broken
* into pieces that can be dragged around.
*/
import java.util.ArrayDeque;

class Puzzle {
  
  private ArrayList<PuzzlePiece> puzzlePieces = new ArrayList<PuzzlePiece>();
  private PuzzlePiece selectedPiece = null;
  private int puzzleWidth, puzzleHeight, puzzleX, puzzleY;
  
  /*
  * Creates a new puzzle based off of an image and a tempalate
  *
  * < Template still needs to be added >
  */
  Puzzle(CImage puzzle){
    puzzleX = puzzle.getX();
    puzzleY = puzzle.getY();
    puzzleWidth = puzzle.getWidth();
    puzzleHeight = puzzle.getHeight();
    int[] puzzlePixels = puzzle.getPixels();
    
    color wallColor = 0x0;          // Walls in template are black  
    color replaceColor = 0x969696;  // Replacement color on template is this
    int currImageIndex;
    
    // This is a very simple flood fill algorithm used to read a black and
    // white image and convert all white areas into multiple pieces.
    // The code below is pretty nasty sorry about that.
    
    ArrayDeque<Integer> stack = new ArrayDeque<Integer>();
    for (int i = 0; i < puzzle.getWidth() * puzzle.getHeight(); i++){
      PuzzlePiece puzzlePiece = new PuzzlePiece();
      stack.push(i);
      while (stack.size() != 0){
        currImageIndex = stack.pop();
        // If current pixel looking at is not within the picture look at another pixel
        if (currImageIndex < 0 || currImageIndex >= (width*height))
          continue;
        // If the current pixel is a pixel already seen, replaced, look at another pixel
        if (isEqualColor(puzzlePixels[currImageIndex], replaceColor, 0))
          continue;
        // If the current pixel is not white, meaning a wall, continue
        if (isEqualColor(puzzlePixels[currImageIndex], wallColor, 255))
          continue;
        // Add the pixel from the source image to the piece and find next pixel
        puzzlePiece.addPixel(currImageIndex, puzzlePixels[currImageIndex]);
        puzzlePixels[currImageIndex] = replaceColor;
        stack.push(currImageIndex-width);
        stack.push(currImageIndex+width);
        stack.push(currImageIndex+1);
        stack.push(currImageIndex-1);
      }
      
      // If the puzzle piece does not have more than 10 pixels ignore it
      if (puzzlePiece.isValidPuzzlePiece())
        puzzlePieces.add(puzzlePiece.convertToCImage());
    }
  }
  
  // Returns if two colors are equal, with a range of ignorance.
  private boolean isEqualColor(color c1, color c2, int diffRange){
    return Math.abs(colorSum(c1)-colorSum(c2)) <= diffRange;
  }
  
  // Returns the sum of the red,green,blue values added
  private int colorSum(color c) {
    return (c & 0xff) + (c >> 8 & 0xff) + (c >> 16 & 0xff);
  }
  
  // Sets the selected piece within the puzzle at the x,y location
  public void selectPiece(int x, int y){
    if (selectedPiece != null) // Do not select if a piece is already selected
      return;
    for (PuzzlePiece pp : puzzlePieces){
      if (pp.containsMouse(x, y)){
        selectedPiece = pp;
      }
    }
  }
  
  // Removes selected puzzle piece in the puzzle
  public void deselectPiece(){
    selectedPiece = null;
  }
  
  // Redraws the puzzle with the specified color puzzle background
  public void render(int backgroundColor){
    // Don't render if no piece is selected, no need to
    if (selectedPiece == null)
      return;
      
    fill(backgroundColor);
    rect(puzzleX, puzzleY, puzzleWidth, puzzleHeight);
    for (PuzzlePiece pp : puzzlePieces)
      if (pp != selectedPiece) // Show all pieces that are not selected
        pp.show();
    selectedPiece.moveTo(mouseX-selectedPiece.getWidth()/2,mouseY-selectedPiece.getHeight()/2);
  }
  
  // Redraws the puzzle with the specified puzzle background image
  public void render(String image) {
    if (selectedPiece == null)
      return;
      
    new CImage(puzzleX, puzzleY, image).show();
    for (PuzzlePiece pp : puzzlePieces)
      if (pp != selectedPiece) // Show all pieces that are not selected
        pp.show();
    selectedPiece.moveTo(mouseX-selectedPiece.getWidth()/2,mouseY-selectedPiece.getHeight()/2);
  }
}
 
