import processing.video.*;

class WebCam {
  
  Capture video;
  
  WebCam(PApplet parent){
    // support for higher resolutions unavailable unfortunately
    try {
      video = new Capture(parent, 640, 480, 30);
      video.start();
    } catch (Exception e) {
      println("ERROR: INIT WebCam");
    }
  }
}
