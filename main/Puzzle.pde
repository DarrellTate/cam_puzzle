/*
* Class represents a puzzle. The puzzle is composed of an image, which is broken
* into pieces that can be dragged around.
*/
import java.util.ArrayDeque;

class Puzzle {
  
  private final int PIECE_CONTAINER_WIDTH = 200;
  
  /*
  * Will move all pieces on the puzzle board to the PieceContainer which
  * holds all the pieces.
  */
  public void scramble(){
    // Removing all pieces from the SnapPoints
    for (SnapPoint sp : snapPoints){
      pieceContainer.addPuzzlePiece(sp.getCurrPiece());
      puzzlePieces.remove(sp.getCurrPiece().getID());
      sp.setCurrPiece(null);
    }
    forceRenderAll();
  }
  
  // Returns whether the puzzle is complete
  public boolean isComplete() {
    for (SnapPoint sp : snapPoints)
      if (!sp.isCorrect())
        return false;
    return true;
  }
  
  // Redraws the puzzle with the specified color puzzle background
  public void render(){
    pieceContainer.render();
    
    if (selectedPiece != null)
      selectedPiece.moveTo(mouseX-selectedPiece.getWidth()/2,mouseY-selectedPiece.getHeight()/2);
    
    // Rendering the puzzle board
    stroke(foreground);
    noFill();
    rect(getX(), getY(), getWidth(), getHeight());
    pieceTemplate.show();
    // Rendering the puzzle pieces that are on the board
    for (PuzzlePiece pp : puzzlePieces.values())
      pp.show();
      
    if (selectedPiece != null)
      selectedPiece.show();
  }
  
    // Sets the selected piece within the puzzle at the x,y location
  public void selectPiece(int x, int y){
    if (selectedPiece != null) // Do not select if a piece is already selected
      return;
    
    selectedPiece = pieceContainer.getPiece(x,y); // Check if piece is in holding container
    if (selectedPiece == null) // Piece is not in holding container
      for (PuzzlePiece pp : puzzlePieces.values())
        if (pp.containsMouse(x, y)){
          selectedPiece = pp;
          for (SnapPoint sp : snapPoints) // Remove the selected piece from SnapPoint
            if (sp.getCurrPiece() == selectedPiece)
              sp.setCurrPiece(null);
          }
   if (selectedPiece != null)
     selectedPiece.restore();
  }
  
  // Removes selected puzzle piece in the puzzle and moves to nearst SnapPoint
  public void deselectPiece(){
    if (selectedPiece == null)
      return;
    
    if (mouseX > X+W){ // Add to piece container / outside puzzle board
      pieceContainer.addPuzzlePiece(selectedPiece);
    } else {
      pieceContainer.removePuzzlePiece(selectedPiece);
      puzzlePieces.put(selectedPiece.getID(), selectedPiece);
      placeAtClosestSnapPoint(selectedPiece);
    }
    selectedPiece = null;
  }
  
  
  
  /*
  * =========================================================
  * Everything below this line is probably not need to be known
  * so no need to worry about it.
  *
  * Enter at your own expense.
  * =========================================================
  */
  
  private final int X, Y, W, H;
  
  private TreeMap<Integer, PuzzlePiece> puzzlePieces = new TreeMap<Integer, PuzzlePiece>();
  private ArrayList<SnapPoint> snapPoints = new ArrayList<SnapPoint>();
  
  private color background, foreground;
  private PuzzlePiece selectedPiece = null;
  private PieceContainer pieceContainer;
  
  private CImage pieceTemplate;
  
  /*
  * Creates a new puzzle based off of an image and a tempalate
  *
  * < Template still needs to be added >
  */
  Puzzle(CImage picture, CImage pieceTemplate, color foreground, color background) {
    this.pieceTemplate = pieceTemplate;
    X = pieceTemplate.getX();
    Y = pieceTemplate.getY();
    W = pieceTemplate.getWidth();
    H = pieceTemplate.getHeight();
    this.foreground = foreground;
    this.background = background;
    
    pieceContainer = new PieceContainer(X + W, Y, PIECE_CONTAINER_WIDTH, H);
    pieceContainer.setColorScheme(foreground, background);
    generatePuzzlePieces(picture.clone(), pieceTemplate.clone());
  }
  
  // This is a very simple flood fill algorithm used to read a black and
  // white image and convert all white areas into multiple pieces.
  // The code below is pretty nasty sorry about that.
  private void generatePuzzlePieces(CImage picture, CImage pieceTemplate){
    int[] templatePixels = pieceTemplate.getPixels();
    int maxPixelIndex = W*H;
    
    color replaceColor = 0x969696;  // Replacement color on template is this
    int currIndex;
    
    ArrayDeque<Integer> stack = new ArrayDeque<Integer>();
    for (int i = 0; i < maxPixelIndex; i++){
      PuzzlePiece puzzlePiece = new PuzzlePiece(this, i);
      stack.push(i);
      while (stack.size() != 0){
        currIndex = stack.pop();
        if (currIndex < 0 || currIndex >= maxPixelIndex)
          continue;
        if (templatePixels[currIndex] == replaceColor)
          continue;
        // If the current pixel is not white, meaning a wall, continue
        if (colorSum(templatePixels[currIndex]) < 255)
          continue;

        puzzlePiece.addPixel(currIndex, picture.getImage().pixels[currIndex]);
        templatePixels[currIndex] = replaceColor;
        
        stack.push(currIndex-pieceTemplate.getWidth());
        stack.push(currIndex+pieceTemplate.getWidth());
        stack.push(currIndex+1);
        stack.push(currIndex-1);
      }
      
      if (puzzlePiece.isValidPuzzlePiece()){
        PuzzlePiece pp = puzzlePiece.convertToCImage();
        puzzlePieces.put(pp.getID(), pp);
        snapPoints.add(new SnapPoint(pp));
      }
    }
  }
  
  // Returns the sum of the red,green,blue values added
  private int colorSum(color c) {
    return (c & 0xff) + (c >> 8 & 0xff) + (c >> 16 & 0xff);
  }
  
  private void placeAtClosestSnapPoint(PuzzlePiece pp){
    // Adding PuzzlePiece to closest snap point not to pretty
    int minDistance = MAX_INT;
    SnapPoint closestPoint = null;
    for (SnapPoint sp : snapPoints){
      if (!sp.isOccupied()) {
        int tempDist = distanceToSnapPoint(pp, sp);
        if (tempDist < minDistance){
          minDistance = tempDist;
          closestPoint = sp;
        }
      }
    }
    
    if (closestPoint == null){
      return;
    } else if (closestPoint.getX() + pp.getWidth() > X+W) {
      pieceContainer.addPuzzlePiece(pp);
    } else if (closestPoint.getY() + selectedPiece.getHeight() > Y+H) {
      pieceContainer.addPuzzlePiece(selectedPiece);
    } else {
      selectedPiece.moveTo(closestPoint.getX(), closestPoint.getY());
      closestPoint.setCurrPiece(selectedPiece);
      forceRenderAll();
    }
  }
  
  private int distanceToSnapPoint(PuzzlePiece pp, SnapPoint sp){
    return (int) Math.sqrt(Math.pow(Math.abs(pp.getX() - sp.getX()),2) + Math.pow(Math.abs(pp.getY() - sp.getY()), 2));
  }
  
  private void forceRenderAll(){
    pieceContainer.render();
    
    stroke(foreground);
    fill(background);
    rect(getX(), getY(), getWidth(), getHeight());
    for (PuzzlePiece pp : puzzlePieces.values())
      pp.show();
  }
  
    
  public final int getX() {
    return X;
  }
  
  public final int getY() {
    return Y;
  }
  
  public final int getWidth(){
    return W;
  }
  
  public final int getHeight() {
    return H;
  }
  
}
 
