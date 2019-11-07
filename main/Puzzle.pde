/*
* Class represents a puzzle. The puzzle is composed of an image, which is broken
* into pieces that can be dragged around.
*/
import java.util.ArrayDeque;

class Puzzle {
  
  private final color WALL_COLOR = 0x0; //0x29E679; // The wall color in piece template
  private TreeMap<Integer, PuzzlePiece> puzzlePieces = new TreeMap<Integer, PuzzlePiece>();
  private ArrayList<SnapPoint> snapPoints = new ArrayList<SnapPoint>();
  
  private PuzzlePiece selectedPiece = null;
  private PieceContainer pieceContainer;
  
  private final int templateWidth, templateHeight, templateX, templateY;
  private color background, foreground;
  private CImage template;
  
  /*
  * Creates a new puzzle based off of an image and a tempalate
  *
  * < Template still needs to be added >
  */
  Puzzle(CImage pieceTemplate, color foreground, color background) {
    this.template = pieceTemplate;
    templateX = pieceTemplate.getX();
    templateY = pieceTemplate.getY();
    templateWidth = pieceTemplate.getWidth();
    templateHeight = pieceTemplate.getHeight();
    int[] templatePixels = pieceTemplate.getPixels();
    
    this.foreground = foreground;
    this.background = background;
    pieceContainer = new PieceContainer(templateX + templateWidth, templateY, 200, templateHeight, foreground);
    
    color replaceColor = 0x969696;  // Replacement color on template is this
    int currImageIndex;
    int pieceID = 0;
    
    // This is a very simple flood fill algorithm used to read a black and
    // white image and convert all white areas into multiple pieces.
    // The code below is pretty nasty sorry about that.
    
    ArrayDeque<Integer> stack = new ArrayDeque<Integer>();
    for (int i = 0; i < templateWidth * templateHeight; i++){
      PuzzlePiece puzzlePiece = new PuzzlePiece(this, ++pieceID);
      stack.push(i);
      while (stack.size() != 0){
        currImageIndex = stack.pop();
        // If current pixel looking at is not within the picture look at another pixel
        if (currImageIndex < 0 || currImageIndex >= (getWidth()*getHeight()))
          continue;
        // If the current pixel is a pixel already seen, replaced, look at another pixel
        if (isEqualColor(templatePixels[currImageIndex], replaceColor, 0))
          continue;
        // If the current pixel is not white, meaning a wall, continue
        if (isEqualColor(templatePixels[currImageIndex], WALL_COLOR, 255))
          continue;
        // Add the pixel from the source image to the piece and find next pixel
        puzzlePiece.addPixel(currImageIndex, templatePixels[currImageIndex]);
        templatePixels[currImageIndex] = replaceColor;
        
        stack.push(currImageIndex-templateWidth);
        stack.push(currImageIndex+templateWidth);
        stack.push(currImageIndex+1);
        stack.push(currImageIndex-1);
      }
      
      // If the puzzle piece does not have more than 10 pixels ignore it
      if (puzzlePiece.isValidPuzzlePiece()){
        PuzzlePiece pp = puzzlePiece.convertToCImage();
        puzzlePieces.put(pp.getID(), pp);
        snapPoints.add(new SnapPoint(pp.getX(),pp.getY(),pp.getID(), pp.getID()));
      }
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

  /*
  * Will move all pieces on the puzzle board to the PieceContainer which
  * holds all the pieces.
  */
  public void scramble(){
    // Removing all pieces from the SnapPoints
    for (SnapPoint sp : snapPoints){
      pieceContainer.addPuzzlePiece(puzzlePieces.get(sp.getCurrPieceID()));
      puzzlePieces.remove(sp.getCurrPieceID());
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
  
  // Sets the selected piece within the puzzle at the x,y location
  public void selectPiece(int x, int y){
    if (selectedPiece != null) // Do not select if a piece is already selected
      return;
      
    selectedPiece = pieceContainer.getPiece(x,y);
    
    if (selectedPiece == null){
      for (PuzzlePiece pp : puzzlePieces.values()){
        if (pp.containsMouse(x, y)){
          selectedPiece = pp;
        }
      }
    }
    
    // Removing the puzzle piece from the SnapPoint
    if (selectedPiece != null){
      selectedPiece.restore();
      for (SnapPoint sp : snapPoints)
        if (sp.getCurrPieceID() == selectedPiece.getID())
          sp.setCurrPiece(null);
    }
  }
  
  // Removes selected puzzle piece in the puzzle and moves it
  // to the nearest SnapPoint
  public void deselectPiece(){
    if (selectedPiece == null)
      return;
    
    if (mouseX > getX()+getWidth()){
      pieceContainer.addPuzzlePiece(selectedPiece);
      selectedPiece = null;
      return;
    }else{
      pieceContainer.removePuzzlePiece(selectedPiece);
      puzzlePieces.put(selectedPiece.getID(), selectedPiece);
    }
    // Adding PuzzlePiece to closest snap point not to pretty
    int minDistance = MAX_INT;
    SnapPoint closestPoint = null;
    for (SnapPoint sp : snapPoints){
      if (!sp.isOccupied()) {
        int tempDist = distanceToSnapPoint(selectedPiece, sp);
        if (tempDist < minDistance){
          minDistance = tempDist;
          closestPoint = sp;
        }
      }
    }
    
    if (closestPoint == null){
      selectedPiece = null;
    } else {
      selectedPiece.moveTo(closestPoint.getX(), closestPoint.getY());
      closestPoint.setCurrPiece(selectedPiece);
      forceRenderAll();
      selectedPiece = null;
    }
  }
  
  private int distanceToSnapPoint(PuzzlePiece pp, SnapPoint sp){
    return (int) Math.sqrt(Math.pow(Math.abs(pp.getX() - sp.getX()),2) + Math.pow(Math.abs(pp.getY() - sp.getY()), 2));
  }
  
  private void forceRenderAll(){
    fill(background);
    rect(getX(), getY(), getWidth(), getHeight());
    for (PuzzlePiece pp : puzzlePieces.values())
      pp.show();
  }
  
  // Redraws the puzzle with the specified color puzzle background
  public void render(){
    pieceContainer.render();
    
    if (selectedPiece != null)
      selectedPiece.moveTo(mouseX-selectedPiece.getWidth()/2,mouseY-selectedPiece.getHeight()/2);
    
    stroke(foreground);
    fill(background);
    rect(getX(), getY(), getWidth(), getHeight());
    for (PuzzlePiece pp : puzzlePieces.values())
      pp.show();
    if (selectedPiece != null)
      selectedPiece.show();
    //template.show();
  }
  
    
  public int getX() {
    return templateX;
  }
  
  public int getY() {
    return templateY;
  }
  
  public int getWidth(){
    return templateWidth;
  }
  
  public int getHeight() {
    return templateHeight;
  }
  
}
