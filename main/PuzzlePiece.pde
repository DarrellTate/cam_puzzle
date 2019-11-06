/*
* Class that represents a piece within the Puzzle class.
* A PuzzlePiece is an extension of a CImage
*
* This class's main methods come from the CImage class
*
* Everything in this is pretty much not important
*/
class PuzzlePiece extends CImage {
  
  private HashMap<Integer, Integer> pixelMap;
  private int minX, minY, maxX, maxY;
  
  PuzzlePiece(){
    pixelMap = new HashMap<Integer, Integer>();
    minX = width + 1;
    minY = height + 1;
    maxX = -1;
    maxY = -1;
  }
  
  // Takes the pixel index from the template image and the color at that index
  public void addPixel(int i, color c) {
    pixelMap.put(i,c);
    int x = i%width;
    int y = i/height;
    
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
    PImage pieceImg = createImage(w,h,ARGB); // This is the image that will be used to represent the image
    for (int x = 0; x < w; x++){
      for (int y = 0; y < h; y++){
        originalImageIndex = (y+minY)*width+(x+minX);
        if (pixelMap.containsKey(originalImageIndex))
          pieceImg.pixels[y*w+x] = pixelMap.get(originalImageIndex); // Use pixel specified by addPixel
        else
          pieceImg.pixels[y*w+x] = color(150,0,0,0); // Pixels not specified by addPixel will be transparent
      }
    }
    super.setImage(minX, minY, pieceImg);
    super.show(); // Display the newly created piece
    return this;
  }
  
  // A valid piece must have at least 10 pixels
  public boolean isValidPuzzlePiece(){
    return pixelMap.size() >= 10;
  }
}
