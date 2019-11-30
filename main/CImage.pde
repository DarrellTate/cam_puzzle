/*
* Class used to represent an Image as extending PImage is a pain.
*/
class CImage {
  
  private PImage image;
  private int x,y,origWidth,origHeight,shrinkWidth,shrinkHeight;
  
  // Default Constructor
  CImage(){}
  
  /*
  * Creates an image with the top left corner positioned at x,y.
  *
  * Parameters: int x,y - The x,y coordinate of the image
  *             Capture capture - The Capture object
  */
  CImage(int x, int y, int w, int h, WebCam capture){
    this(x,y,w,h,capture.video.get(0,0,capture.video.width,capture.video.height));
  }

  /*
  * Creates an image with the top left corner positioned at x,y.
  *
  * Parameters: int x,y - The x,y coordinate of the image
  *             String imageFileName - The name of the image file to load
  */
  CImage(int x, int y, String imageFileName){
    this(x,y,loadImage(imageFileName));
  }
  
  // Allows for resizing
  CImage(int x, int y, int w, int h, String imageFileName){
    this(x,y,imageFileName);
    image.resize(w,h);
  }
  
  /*
  * Stores an image with the top left corner positioned at x,y.
  *
  * Parameters: int x,y - The x,y coordinate of the image
  *             PImage image - The image to store
  */
  CImage(int x, int y, PImage image){
    this.x = x;
    this.y = y;
    this.image = image;
    this.origWidth = image.width;
    this.origHeight = image.height;
  }
  
  CImage(int x, int y, int w, int h, PImage image){
    this(x,y,image);
    image.resize(w,h);
  }
  
  public CImage clone() {
    return new CImage(getX(), getY(), getWidth(), getHeight(),this.getImage().copy());
  }

  /*
  * Sets this CImage to the PImage provided
  *
  * Parameters: int x,y - The top left hand corner location of the image
  *             PImage - The image to set
  */
  public CImage setImage(int x, int y, PImage image){
    this.x = x;
    this.y = y;
    this.image = image;
    this.origWidth = image.width;
    this.origHeight = image.height;
    return this;
  }
  
    // Displays the image at its x,y position
  public void show() {
    if (image == null)
      return;
    image(image,x,y);
  }
  
  // Will resize the image to the specified shrink size
  public void shrink(){
    if (shrinkWidth > 0 && shrinkHeight > 0)
      image.resize(shrinkWidth,shrinkHeight);
  }
  
  // Restores the image to the original size when first created
  public void restore(){
    if (image != null)
      image.resize(origWidth, origHeight);
  }
  
  /*
  * Moves the images top left corner to the new x,y values 
  * and shows the image in the new position.
  */
  public void moveTo(float x, float y){
    this.x = (int) x;
    this.y = (int) y;
    // TODO: This method gets called every frame, BAD, because of Caleb, probably not to be honest.
  }
  
  // Returns if the mouse is within the image
  public boolean containsMouse(int x, int y){
    if (x > this.x && x < this.x + getWidth())
      if (y > this.y && y < this.y + getHeight())
        if (alpha(image.pixels[(y-this.y) * image.width+(x-this.x)]) != 0)
          return true;
    return false;
  }
  
  // Changes the size of the image
  public void setShrinkSize(int w, int h) {
    shrinkWidth = w;
    shrinkHeight = h;
  }
  
  // Returns all pixels in the image
  public int[] getPixels(){
    image.loadPixels();
    return image.pixels;
  }
  
  // Returns the image
  public PImage getImage(){
    return image;
  }
    
  // Returns the x position of the image
  public int getX(){
    return x;
  }
  
  // Returns the y position of the image
  public int getY(){
    return y;
  }
  
  // Returns the width of the image
  public int getWidth(){
    return image != null ? this.image.width : -1;
  }
  
  // Returns the height of the image
  public int getHeight(){
    return image != null ? this.image.height : -1;
  }

  public void updatePixels() {
    image.updatePixels();
  }

  public void setPixel(int pixelIndex, color c) {
      if (alpha(image.pixels[pixelIndex]) == 0)
          return;
      image.pixels[pixelIndex] = c;
  }
}
