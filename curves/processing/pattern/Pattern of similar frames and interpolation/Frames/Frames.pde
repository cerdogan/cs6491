// LecturesInGraphics: vector interpolation
// Template for sketches
// Author: Jarek ROSSIGNAC

//**************************** global variables ****************************
pts P = new pts();
float t=1, f=0;
Boolean animate=true, linear=false, circular=false, beautiful=false, showFrames=true;
float len=60; // length of arrows
//**************************** initialization ****************************
void setup() {               // executed once at the begining 
  //size(600, 600, P3D);            // window size
  size(600, 600);            // window size
  frameRate(30);             // render 30 frames per second
  smooth();                  // turn on antialiasing
  myFace = loadImage("data/pic.jpg");  // load image from file pic.jpg in folder data *** replace that file with your pic of your own face
  textureMode(NORMAL);
  P.declare().resetOnCircle(6);
  P.loadPts("data/pts");
  }

//**************************** display current frame ****************************
void draw() {      // executed at each frame
  background(white); // clear screen and paints white background
  if(snapPic) beginRecord(PDF,PicturesOutputPath+"/P"+nf(pictureCounter++,3)+".pdf"); 
  
  F0 = F(P.G[0],P.G[1]); 
  F1 = F(P.G[2],P.G[3]);
  E0  = F(P.G[4],P.G[5]);
  // Show user-controlled Frames 
 
  penFill(green,3);  showArrows(F0); // show the start frame F0 as arrows
  penFill(blue,3);  showArrows(F1); // show the second frame F1 (will be hidden by blue iteration)
    
  penFill(magenta,3);   showArrow(E0);  // show magenta decoration arrow 
 
  F1rF0 = F0.invertedOf(F1);
  E0rF0 = F0.invertedOf(E0);
  F=F(F0); E=F(E0);
  for(int i=0; i<k; i++) {
     F=F.of(F1rF0); 
     if(showFrames) {penFill(blue,3); showArrows(F);}
     E=F.of(E0rF0); 
     if(showFrames)  {pen(magenta,3,magenta); showArrow(E);}
     Fk = F(F);
     }

  penFill(red,3);    showArrows(Fk); // show last frame Fk as red arrows
  Ft = F(F0,t,Fk); penFill(black,3);    showArrows(Ft); // show intermediate frame of morph (F0,t,Fk);
  Et=Ft.of(E0rF0); penFill(magenta,3);   showArrow(Et); 
  
  if(animating) {t+=0.01; if(t>=1) {t=1; animating=false;}} 

  pen(black,1,white); P.draw(3);

  if(snapPic) {endRecord(); snapPic=false;} // end saving a .pdf of the screen

  fill(black); displayHeader();
  if(scribeText && !filming) displayFooter(); // shows title, menu, and my face & name 
  if(filming && (animating || change)) saveFrame("FRAMES/F"+nf(frameCounter++,4)+".tif"); // saves a movie frame 
  change=false; // to avoid capturing movie frames when nothing happens
  }  // end of draw()
  
//**************************** user actions ****************************
void keyPressed() { // executed each time a key is pressed: sets the "keyPressed" and "key" state variables, 
                    // till it is released or another key is pressed or released
  if(key=='?') scribeText=!scribeText; // toggle display of help text and authors picture
  if(key=='!') snapPicture(); // make a picture of the canvas and saves as .jpg image
  if(key=='`') snapPic=true; // to snap an image of the canvas and save as zoomable a PDF
  if(key=='~') { filming=!filming; } // filming on/off capture frames into folder FRAMES 
  if(key=='a') {animating=true; f=0; t=0;}  
  if(key=='s') P.savePts("data/pts");   
  if(key=='l') P.loadPts("data/pts"); 
  if(key=='f') showFrames=!showFrames;
  if(key=='Q') exit();  // quit application
  change=true; // to make sure that we save a movie frame each time something changes
  }

void mousePressed() {  // executed when the mouse is pressed
  P.pickClosest(Mouse()); // used to pick the closest vertex of C to the mouse
  change=true;
  }

void mouseDragged() {
  if (!keyPressed || (key=='a')) P.dragPicked();   // drag selected point with mouse
  if (keyPressed) {
      if (key=='.') f+=2.*float(mouseX-pmouseX)/width;  // adjust current frame   
      if (key=='t') P.dragAll(); // move all vertices
      if (key=='r') P.rotateAllAroundCentroid(Mouse(),Pmouse()); // turn all vertices around their center of mass
      if (key=='z') P.scaleAllAroundCentroid(Mouse(),Pmouse()); // scale all vertices with respect to their center of mass
      }
  change=true;
  }  

//**************************** text for name, title and help  ****************************
String title ="6491 2015 P2: Steady Interpolating of Similarities in 2D", 
       name ="Student: ??? ??????",
       menu="?:(show/hide) help, a: animate, `:snap picture, ~:(start/stop) recording movie frames, Q:quit",
       guide="click and drag to edit, f:showFrames"; // help info

void drawObject(pt P, vec V) {
  beginShape(); 
    texture(myFace);
    v(P(P(P,1,V),1,R(V)),0,0);
    v(P(P(P,1,V),-1,R(V)),1,0);
    v(P(P(P,-1,V),-1,R(V)),1,1);
    v(P(P(P,-1,V),1,R(V)),0,1); 
  endShape(CLOSE);
  }
 
  void drawObjectS(pt P, vec V) {
  beginShape(); 
    v(P(P(P,1,V),0.25,R(V)));
    v(P(P(P,1,V),-0.25,R(V)));
    v(P(P(P,-1,V),-0.25,R(V)));
    v(P(P(P,-1,V),0.25,R(V))); 
  endShape(CLOSE);
  }
  
float timeWarp(float f) {return sq(sin(f*PI/2));}