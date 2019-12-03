private Puzzle puzzle;
// Array of templates. 
// TODO: Add to this array as you add more templates
String[] templates = {"Template1.png", "Template2.png"};

private final color GREEN = color(41,230,118);
/*
                                    * * * * * TODO * * * * *
      
~ Uncomment out the actual puzzle feature and add it to page 1 where the timer is
    * make it fit the 600x600 checkered canvas
~ Finish page 3: the losing screen (the "virus infection") - add more trippy shit to it
~ Create mechanism for determining if puzzle is complete
    * if puzzle is complete, just set global variable gameWon to 1
    * this will automatically switch page to page 2, the winning screen
~ Finish page 2: the winning screen - just make sure it works fine
~ Incorporate the webcam feature so we can create puzzle pieces out of webcame images
    * We can implement this between pages 0 and 1, page 0b or something
~ Implement glitching feature to puzzle pieces
    * figure out when to glitch each piece too
*/

int page = 0;
PFont font;

// For WebCam
WebCam webCamSnap1, webCamSnap2;
boolean camsStarted = false;
boolean loadedMenu = false;

// For Page 0: The Messages
float x = 200;
float y = 100;
int textCounter = 1;
String page0Message = "";

// For Page 1: The Puzzle Game
int page1Counter = 0; // This is to create the effect of generating page 1's features
int timer = width; // RANGE: [0, 1200]
int gameWon = 0;
PImage checkeredImage;
int puzzleInitialized = 0; // 0 = false, 1 = true

// For Page 2: The Winning Page
String page2Message = "Congratulations, you win!\n\nYour machine has been spared.\n";
int page2Counter = 0;

// For Page 3: The Losing Page
String page3Message = "Sorry, you lose :(\n\nTime for a new computer.\n";
int page3Counter = 0;
int delayDone = 0; // This variable is just to make sure we only do the 2 second delay once

void setup(){
  // for unkown reasons, you MUST set webcam first ... possibly to set "this"?
  thread("setupCams"); // Running a new thread to prevent the screen from locking
  fullScreen();
  //size(1200,900);
  background(0);
  // a 600x600 "canvas". for dragging the puzzle pieces into
  checkeredImage = loadImage("resources/checkered600x600.png"); 
  showPage0();
}

void setupCams(){
  webCamSnap1 = new WebCam(this);
  webCamSnap2 = new WebCam(this);
  camsStarted = true;
}

String generateRandomTemplate() {
    int randomIndex = (int) random(templates.length);
    return templates[randomIndex];
}

void setupPuzzle() {
  try {
    CImage picture = new CImage(250,100,600,600, webCamSnap1.video);
    webCamSnap1.video.stop();
    CImage replacementPicture = new CImage(250,100,600,600, loadImage("resources/puzzle1.jpg"));
    webCamSnap2.video.stop();
    
    String templateName = generateRandomTemplate();
    CImage template = new CImage(250,100,600,600,loadImage("resources/" + templateName));
    puzzle = new Puzzle(picture, template, replacementPicture, GREEN, 0x0); 
    picture = null;
    puzzle.scramble();
  } catch (Exception e) {
    println("ERROR: webCamSnap Buffer Under Flow");
  }
}

void draw(){
  surface.setTitle("Frame: " + frameRate);
  
  if (page==0) {
    typeMessage();
  } else if (page==1) {
    showPage1();
  } else if (page==2) {
    showPage2(); 
  } else if (page==3) {
    showPage3(); 
  }
  
}

void mousePressed() {
  
  
  // TODO: if page is 0:
    // if mouseX and mouseY are within the ranges of the button
  if (page==0 && loadedMenu) {
    if (mouseX >= 500 && mouseX <= 700) {
      if (mouseY >= 500 && mouseY <= 600) {
        page=1;
        showPage1();
      }
    }
  } else if (page==1) {
    puzzle.selectPiece(mouseX, mouseY);
  }
}

void mouseReleased() {
  if (page==1 && page1Counter==3) {
    puzzle.deselectPiece();
    println(puzzle.isComplete());
  }
  
}

/*        
                      PAGE 0 STUFF  
*/
void showPage0() {
  // For the Message
  page0Message += "Welcome....\n\n";
  page0Message += "Virus successfully generated.\n";
  page0Message += "If you exit the program or fail to solve the puzzle\n";
  page0Message += "before the time runs out, the virus will be released\n";
  page0Message += "into your machine. Press BEGIN to start the timer.\n\n";
  page0Message += "Good luck.\n";
}

void typeMessage() {
  if (textCounter<page0Message.length()) {
    textCounter++;
    font = createFont("Monospaced",24);
    textFont(font);
    fill(41,230,118);
    textAlign(LEFT);
    text(page0Message.substring(0,textCounter),x,y);
  } else if (textCounter==page0Message.length() && camsStarted) {
    showPage0Button();
    textCounter++;
    loadedMenu = true;
  }
}
void showPage0Button() {
  stroke(41,230,118);
  fill(0);
  strokeWeight(3);
  rect(500,500,200,100,10);
  textSize(40);
  textAlign(CENTER);
  fill(41,230,118);
  text("BEGIN",500,525,200,100); 
}

/*        
                      PAGE 1 STUFF  
*/
void showPage1() {
  // set up black background
  if (page1Counter==0) {
    background(0);
    page1Counter++;
  } 
  // set up timer
  else if (page1Counter==1) {
    if (timer!=width) {
      timer += 20;
      setTimer(0,0,timer,50);
    } else {
      // at this point, timer is 1200 aka FULL
      // so we move on to the next page set up
      page1Counter++;
    }
  } else if (page1Counter==2) {
    // TODO: now we set up the checkered image in the middle 
    //image(checkeredImage,300,75);
    // TODO: include and scramble the puzzle pieces
    
    if (puzzleInitialized==0) {
      setupPuzzle();
      puzzleInitialized=1;
    }
    page1Counter++;
    
  } else if (page1Counter==3) {
    // at this point, timer will keep getting decreased
    puzzle.render();
    setTimer(0,0,--timer,50);
    
    // TODO: if timer gets to 0, set gameWon to 1
    if (timer==0) {
      if (gameWon==1) {
        // Set page to 2: The winning Screen
        page = 2;
      } else {
        // Set page to 3: Virus infection
        page = 3;
      }
    }
    
  }
  
}

// Event Listener for Capture devise
// updates the capture buffer with the current available capture frame
// must exist in main so that the event can be triggered!!!
void captureEvent(Capture video){
  video.read();
}

void setTimer(int theX, int theY, int theW, int theH) {
  fill(0);
  rect(theX,theY,width,theH);
  fill(41,230,118);
  rect(theX,theY,theW,theH);
}

// TODO: FINISH PAGE 2 - WINNING PAGE
void showPage2() {
  typeMessagePage2();
}
void typeMessagePage2() {
  if (page2Counter==0) {
    background(0);
    page2Counter++;
  }
  if (page2Counter<page2Message.length()) {
    page2Counter++;
    font = createFont("Monospaced",40);
    textFont(font);
    fill(41,230,118);
    textAlign(LEFT);
    text(page2Message.substring(0,page2Counter),x,y);
  } else if (page2Counter==page2Message.length()) {
    // that way it doesn't keep calling the conditional
    page = -1;
  }
}

// PAGE3 - LOSING PAGE
void showPage3() {
  typeMessagePage3();
}
void typeMessagePage3() {
  if (page3Counter==0) {
    background(0);
    page3Counter++;
  }
  else if (page3Counter<page3Message.length()) {
    page3Counter++;
    font = createFont("Monospaced",40);
    textFont(font);
    fill(41,230,118);
    textAlign(LEFT);
    text(page3Message.substring(0,page3Counter),x,y);
  } else if (page3Counter==page3Message.length()) {
    if (delayDone==0) {
      delay(2000);
      delayDone = 1;
    }
    // TODO: do some trippy shit here
    // not just make screen size change
    surface.setSize((int)random(1500), (int)random(700));
  }
}
