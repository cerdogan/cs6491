/**
 * @file collidingBalls.pde
 * @author Jarek Rossignac, Can Erdogan
 * @date 2015-09-01
 * @brief A processing program to visualize a set of balls colliding bounded in a cube bounding box. Assignment 1 for CS 6941 class.
 * Initial code provided by Prof. Rossignac, and as assignment, Can Erdogan fills out the collision checking/handling segment.
 */

/* *************************************************************************************************************************************************/
// Visualization options

float dz=-150f; // distance to camera. Manipulated with wheel or when 
float rx=-0.06*TWO_PI, ry=-0.04*TWO_PI;    // view angles manipulated when space pressed but not mouse
pt F = P(0,0,0);  // focus point:  the camera is looking at it (moved when 'f or 'F' are pressed
pt Of=P(100,100,0), Ob=P(110,110,0); // red point controlled by the user via mouseDrag : used for inserting vertices ...
Boolean animating=true, tracking=false, center=true, showNormals=false;
float w=400; // half-size of the cube
boolean stop=false; // stops animation if computation took  more than u
boolean individual=false;  //< stops animation when two balls collide
boolean showV=false; 
float t0=0, t1=0, t2=0, t3=0, t4=0, dt01=0, dt12=0, dt23=0, dt34=0; // ti = lap times per frame, and durations in % of u
int Frate=20;
float u = 1./Frate; // time between consecutive frames

/* *************************************************************************************************************************************************/
// Physics options

float t=0; // animation time
float s=0; // no idea...
float mv=1; // magnifier of max initial speed of the balls
int nbs = 2; // number of balls = nbs*nbs*nbs
float br = 20; // ball radius
int collisions=0;  // # of collisions

/* *************************************************************************************************************************************************/
void setup() {
  
  // Setup the screen
  myFace = loadImage("data/pic.jpg");  
  textureMode(NORMAL);          
  size(600, 600, P3D); // p3D means that we will do 3D graphics
  
  // Declare 3 sets of balls (we advect and animate P, othres used for copy
  P.declare(); 
  Q.declare(); 
  PtQ.declare(); 
  
  // Enforce relationship between ball volume and the cube volume
  br=w/(nbs*pow(PI*120/4,1./3));
  P.initPointsOnGrid(nbs,w,br,cyan);
  F = P();
  
  // Set the sphere detail and the framerate (affects visualization cpu usage)
  sphereDetail(6);
  frameRate(Frate);
  noSmooth();
}

/* *************************************************************************************************************************************************/
void draw() {
  t0 = millis();
  background(255);
  pushMatrix();   // to ensure that we can restore the standard view before writing on the canvas
  
    camera();       // sets a standard perspective
    translate(width/2,height/2,dz); // puts origin of model at screen center and moves forward/away by dz
    lights();  // turns on view-dependent lighting
    rotateX(rx); rotateY(ry); // rotates the model around the new origin (center of screen)
    rotateX(PI/2); // rotates frame around X to make X and Y basis vectors parallel to the floor
    if(center) translate(-F.x,-F.y,-F.z);
    noStroke(); // if you use stroke, the weight (width) of it will be scaled with you scaleing factor
    showFrame(50); // X-red, Y-green, Z-blue arrows
    fill(yellow); pushMatrix(); translate(0,0,-w/2-1.5); box(w,w,1); popMatrix(); // draws floor as thin plate
    noFill(); stroke(black); showBlock(w,w,w,0,0,0  ,0);
    fill(magenta); show(F,4); // magenta focus point (stays at center of screen)
    fill(magenta,100); showShadow(F,5); // magenta translucent shadow of focus point (after moving it up with 'F'

//   fill(magenta); noStroke(); show(pick(mouseX,mouseY),10);
   computeProjectedVectors(); // computes screen projections I, J, K of basis vectors (see bottom of pv3D): used for dragging in viewer's frame    
   pp=P.idOfVertexWithClosestScreenProjectionTo(Mouse()); // id of vertex of P with closest screen projection to mouse (us in keyPressed 'x'...

   t1 = millis();
   // your physics module that compute future events goes here
   collisions=0;
   if(animating && !stop) {P.advectBalls(mv); P.resetColors(cyan); P.bounceBalls(w);} // advection

   t2 = millis();
   // your animation module that simulates ball motion between framesgoes here
 
   t3 = millis();
   P.showBalls(); 
   if(showV) P.showVelocities(br*2); 
   pt Picked = pick( mouseX, mouseY);
   if(picking) {P.pickClosestTo(Picked); picking=false;}
   P.showPickedBall();

   fill(blue); show(Picked,3); fill(red,100); showShadow(Picked,5,-w/2);  // show picked point and its shadow
   
   popMatrix(); // done with 3D drawing. Restore front view for writing text on canvas

      // for demos: shows the mouse and the key pressed (but it may be hidden by the 3D model)
      //  if(keyPressed) {stroke(red); fill(white); ellipse(mouseX,mouseY,26,26); fill(red); text(key,mouseX-5,mouseY+4);}
      
  if(scribeText) {fill(black); displayHeader();} // dispalys header on canvas, including my face
  if(scribeText && !filming) displayFooter(); // shows menu at bottom, only if not filming
  if (animating) { t+=PI/180/2; if(t>=TWO_PI) t=0; s=(cos(t)+1.)/2; } // periodic change of time 
  t4 = millis();
  if(!stop) {dt01=(t1-t0)/10/u; dt12=(t2-t1)/10/u; dt23=(t3-t2)/10/u; dt34=(t4-t3)/10/u;}
  scribe("nbs = "+nbs+", "+(nbs*nbs*nbs)+" balls, "+nf(collisions,3,0)+" collisions per frame",10,40); 
  scribe("dt01 = "+nf(dt01,2,1)+"%, dt12 = "+nf(dt12,2,1)+"%, dt23 = "+nf(dt23,2,1)+"%, dt34 = "+nf(dt34,2,1)+"%",10,60); 
  if(filming && (animating || change)) 
    saveFrame("FRAMES/F"+nf(frameCounter++,4)+".png");  // save next frame to make a movie

  if((t4-t0)/10/u>99 || stop) {
    scribe("dt01 = "+nf(dt01,2,1)+"%, dt12 = "+nf(dt12,2,1)+"%, dt23 = "+nf(dt23,2,1)+"%, dt34 = "+nf(dt34,2,1)+"%. STOPPED !",10,80); 
    stop=true;
    }
  change=false; // to avoid capturing frames when nothing happens (change is set uppn action)
}

/* *************************************************************************************************************************************************/
void keyPressed() {
  if(key=='`') picking=true; 
  if(key=='?') scribeText=!scribeText;
  if(key=='!') snapPicture();
  if(key=='~') filming=!filming;
  if(key=='/') stop=!stop;
  if(key=='v') showV=!showV;
  
  // Stop animation when two balls collide (see balls.pde)
  if(key=='I') individual=!individual;
  
  if(key=='i') {P.initPointsOnGrid(nbs,w,br,cyan); stop=false;}
  if(key=='a') animating=!animating; // toggle animation
  if(key=='h') {F = P();}  // "home": reserts Focus point F
  if(key=='+') {nbs++; br=w/(nbs*pow(PI*120/4,1./3)); P.initPointsOnGrid(nbs,w,br,cyan); stop=true;}
  if(key=='-') {nbs=max(1,nbs-1); br=w/(nbs*pow(PI*120/4,1./3)); P.initPointsOnGrid(nbs,w,br,cyan); stop=true;}
  
  // Restart animation
  if(key=='r') {br=w/(nbs*pow(PI*120/4,1./3)); P.initPointsOnGrid(nbs,w,br,cyan); stop=true;}
  
  // Change sphere detail
  if(key=='4') sphereDetail(4);
  if(key=='5') sphereDetail(5);
  if(key=='6') sphereDetail(6);
  if(key=='7') sphereDetail(7);
  if(key=='8') sphereDetail(8);
  if(key=='9') sphereDetail(9);
  if(key=='0') sphereDetail(10);
  if(key=='1') sphereDetail(11);
  if(key=='2') sphereDetail(12);
  if(key=='|') ;
  if(key=='G') ;
  if(key=='q') Q.copyFrom(P); // to save current configuration
  if(key=='p') P.copyFrom(Q); // to restore it
  if(key=='e') {PtQ.copyFrom(Q);Q.copyFrom(P);P.copyFrom(PtQ);}
  if(key=='c') center=!center; // snaps focus F to the selected vertex of P (easier to rotate and zoom while keeping it in center)
  if(key=='t') tracking=!tracking; // snaps focus F to the selected vertex of P (easier to rotate and zoom while keeping it in center)
  if(key=='x' || key=='z' || key=='d') P.setPickedTo(pp); // picks the vertex of P that has closest projeciton to mouse
  if(key=='d') P.deletePicked();
  if(key=='i') P.insertClosestProjection(Of); // Inserts new vertex in P that is the closeset projection of O
  if(key=='W') {P.saveBALLS("data/BALLS"); Q.saveBALLS("data/BALLS2");}  // save vertices to BALLS2
  if(key=='L') {P.loadBALLS("data/BALLS"); Q.loadBALLS("data/BALLS2");}   // loads saved model
  if(key=='w') P.saveBALLS("data/BALLS");   // save vertices to BALLS
  if(key=='l') P.loadBALLS("data/BALLS"); 
  if(key=='#') exit();
  change=true;
  }

/* *************************************************************************************************************************************************/
void mouseWheel(MouseEvent event) {
  dz += event.getAmount();

  change=true;
}

/* *************************************************************************************************************************************************/
void mousePressed() {
   if (!keyPressed) picking=true;
}

/* *************************************************************************************************************************************************/
void mouseMoved() {
  if (keyPressed && key==' ') {rx-=PI*(mouseY-pmouseY)/height; ry+=PI*(mouseX-pmouseX)/width;};
  if (keyPressed && key=='s') dz+=(float)(mouseY-pmouseY); // approach view (same as wheel)
  // if (keyPressed && key=='v') { //**<01 
  //     u+=(float)(mouseX-pmouseX)/width;  u=max(min(u,1),0);
  //     v+=(float)(mouseY-pmouseY)/height; v=max(min(v,1),0); 
  //     } 
  }
  
/* *************************************************************************************************************************************************/
void mouseDragged() {
  if (!keyPressed) {Of.add(ToIJ(V((float)(mouseX-pmouseX),(float)(mouseY-pmouseY),0))); }
  if (keyPressed && key==CODED && keyCode==SHIFT) {Of.add(ToK(V((float)(mouseX-pmouseX),(float)(mouseY-pmouseY),0)));};
  if (keyPressed && key=='x') P.movePicked(ToIJ(V((float)(mouseX-pmouseX),(float)(mouseY-pmouseY),0))); 
  if (keyPressed && key=='z') P.movePicked(ToK(V((float)(mouseX-pmouseX),(float)(mouseY-pmouseY),0))); 
  if (keyPressed && key=='X') P.moveAll(ToIJ(V((float)(mouseX-pmouseX),(float)(mouseY-pmouseY),0))); 
  if (keyPressed && key=='Z') P.moveAll(ToK(V((float)(mouseX-pmouseX),(float)(mouseY-pmouseY),0))); 
  if (keyPressed && key=='f') { // move focus point on plane
    if(center) F.sub(ToIJ(V((float)(mouseX-pmouseX),(float)(mouseY-pmouseY),0))); 
    else F.add(ToIJ(V((float)(mouseX-pmouseX),(float)(mouseY-pmouseY),0))); 
    }
  if (keyPressed && key=='F') { // move focus point vertically
    if(center) F.sub(ToK(V((float)(mouseX-pmouseX),(float)(mouseY-pmouseY),0))); 
    else F.add(ToK(V((float)(mouseX-pmouseX),(float)(mouseY-pmouseY),0))); 
    }
  if (keyPressed && key=='m') {mv+=(float)(mouseX-pmouseX)/width;} // adjust animation speed
  if (keyPressed && key=='b') {br+=10.*(float)(mouseX-pmouseX)/width; P.initPointsOnGrid(nbs,w,br,cyan); stop=true;} // adjust animation speed
  }  

/* *************************************************************************************************************************************************/
// **** Header, footer, help text on canvas
void displayHeader() { // Displays title and authors face on screen
    scribeHeader(title,0); scribeHeaderRight(name); 
    fill(white); 
    // image(myFace, width-myFace.width/2,25,myFace.width/2,myFace.height/2); 
}

/* *************************************************************************************************************************************************/
void displayFooter() { // Displays help text at the bottom
    scribeFooter(guide,1); 
    scribeFooter(menu,0); 
    }

/* *************************************************************************************************************************************************/
String title ="6491-2015-P1: Animation of colliding balls", name ="Can Erdogan",
       menu="?:help, !:picture, ~:videotape, space:rotate, s/wheel:closer, f/F:refocus, a:anim, #:quit",
       guide="i:reinitialize, a:animate, v:show Vs, +/-: # balls. DRAG b:radius, m:faster"; 
       // user's guide