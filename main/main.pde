private Puzzle puzzle;
String[] templates = {"Glass1.png", "Glass2.png", "Glass3.png", "Glass4.png", "Glass5.png", "Glass6.png", "Glass7.png", "Glass8.png", "Glass9.png", "Glass10.png", "Glass11.png", "Glass12.png", "Glass13.png"};
String[] replacement = {"r1.jpg", "r2.jpg", "r3.png", "r4.jpg", "r5.jpg"};

private final color GREEN = color(41,230,118);

int page = 0;
PFont font;

// For WebCam
WebCam webCamSnap1;
boolean camsStarted = false;
boolean loadedMenu = false;

// For Page 0: The Messages
float x = 200;
float y = 100;
int textCounter = 1;
String page0Message = "";

// For Page 1: The Puzzle Game
int page1Counter = 0; // This is to create the effect of generating page 1's features
float timer = (float) width; 
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
  camsStarted = true;
}

String generateRandomTemplate() {
    int randomIndex = (int) random(1,6);
    return templates[randomIndex];
}

void setupPuzzle() {
  try {
    CImage picture = new CImage(250,100,600,600, webCamSnap1.video);
    webCamSnap1.video.stop();
    CImage replacementPicture = new CImage(250,100,600,600, loadImage("resources/" + replacement[(int) random(0, replacement.length)]));
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
    delay(500);
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
    if (puzzleInitialized==0) {
      setupPuzzle();
      puzzleInitialized=1;
    }
    page1Counter++;
    
  } else if (page1Counter==3) {
    // at this point, timer will keep getting decreased
    puzzle.render();
    timer -= 0.5;
    setTimer(0,0,timer,50);
    
    if (puzzle.isComplete()) {
      delay(2000);
      page = 2;
    }
    if (timer==0) {
      page = 3;
    }
    
  }
  
}

// Event Listener for Capture devise
// updates the capture buffer with the current available capture frame
// must exist in main so that the event can be triggered!!!
void captureEvent(Capture video){
  video.read();
}

void setTimer(int theX, int theY, float theW, int theH) {
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
    surface.setSize((int)random(1500), (int)random(700));
  }
}
