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
boolean stop=false; // stops animation if computation took  more than u
boolean individual=false;  //< stops animation when two balls collide
boolean showV=false; 
float t0=0, t1=0, t2=0, t3=0, t4=0, dt01=0, dt12=0, dt23=0, dt34=0; // ti = lap times per frame, and durations in % of u
int Frate=20;


/* *************************************************************************************************************************************************/
// Physics options

float frameTime = 1./Frate; // time between consecutive frames, used to be 'u' 
float animationTime = 0; // animation time

float s=0; // no idea...
float mv=1; // magnifier of max initial speed of the balls
int nbs = 2; // number of balls = nbs*nbs*nbs
float br = 20; // ball radius
float w=400; // half-size of the cube 
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
/// Sets up the camera view, the box, the ground and etc.
void setupScene() {
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
  
  computeProjectedVectors(); // computes screen projections I, J, K of basis vectors (see bottom of pv3D): used for dragging in viewer's frame    
  pp=P.idOfVertexWithClosestScreenProjectionTo(Mouse()); // id of vertex of P with closest screen projection to mouse (us in keyPressed 'x'...
}

/* *************************************************************************************************************************************************/
float wallCollisionTime (pt P, vec V) {
  
  // Handle the wall on the -x
  float time_xn = (-w/2 + br - P.x) / (V.x);
  float time_xp = (w/2 - br - P.x) / (V.x);
  float time_yn = (-w/2 + br - P.y) / (V.y);
  float time_yp = (w/2 - br - P.y) / (V.y);
  float time_zn = (-w/2 + br - P.z) / (V.z);
  float time_zp = (w/2 - br - P.z) / (V.z);
  
  // Find the minimum positive value
  float minTime = 10000.0;
  if((time_xn > 0) && (time_xn < minTime)) minTime = time_xn;
  if((time_xp > 0) && (time_xp < minTime)) minTime = time_xp;
  if((time_yn > 0) && (time_yn < minTime)) minTime = time_yn;
  if((time_yp > 0) && (time_yp < minTime)) minTime = time_yp;
  if((time_zn > 0) && (time_zn < minTime)) minTime = time_zn;
  if((time_zp > 0) && (time_zp < minTime)) minTime = time_zp;
  
  return minTime;
}

/* *************************************************************************************************************************************************/
float ballsCollisionTime (pt P1, vec V1, pt P2, vec V2) {
  
  // Get the coefficients of the quadratic equation in time
  vec v21 = M(V2,V1);
  float a = dot(v21,v21);
  vec p21 = V(P1,P2);
  float b = 2 * dot(p21,v21);
  float c = dot(p21,p21) - 4 * br * br;
  
  // Solve the quadratic
  float discriminant = b*b - 4*a*c;
  if(discriminant < 0) return -1;
  float disSqrt = sqrt(discriminant);
  float sol1 = (-b - disSqrt) / (2 * a);
  float sol2 = (-b + disSqrt) / (2 * a);
  if((sol1 < 0) && (sol2 < 0)) return -1;
  
  // Return the minimal positive solution
  if(sol1 < 0) return sol2;
  else return sol1;
}

/* *************************************************************************************************************************************************/
Boolean stopForever = false;
float firstCollisionTime = 10000000; // for the individual part of the project
Boolean collisionTimeSet = false;
float motionTime = 0.0;
void draw() {
  
  print ("stopForever: " + stopForever + ", firstCollisionTime: " + firstCollisionTime + ", motionTime: " + motionTime + "\n");
  
  // Part 1: Setup the scene
  t0 = millis();
  setupScene();
  t1 = millis();
   
  // -------------------------------------------------------------------------------------------------
  // Part 2: Handle physics
  collisions=0;

  // Find the first collision time
  Boolean wallCase = false;
  float minTime = 10000000.0;
  int p1 = -1, p2 = -1;    //< indices for the first collision
  for (int v=0; v<P.nv; v++) {
    
    // Check for ball-ball collisions
    for (int v2=v+1; v2<P.nv; v2++) {
      float time = ballsCollisionTime(P.G[v], P.V[v], P.G[v2], P.V[v2]);
      if((time > 0) && (time < minTime)) {
        minTime = time;
        p1 = v;
        p2 = v2;
        wallCase = false;
      }
    }
    
    // Check for ball-wall collisions
    float time = wallCollisionTime(P.G[v], P.V[v]);
    if(time < minTime) {
      minTime = time;
      p1 = v;
      p2 = -1;
      wallCase = true;
    }
  }

  // Set the first collision time
  if(!collisionTimeSet) {
    firstCollisionTime = motionTime + minTime;
    collisionTimeSet = true;
  }
  
  print ("minTime: " + minTime + ", (" + p1 + ", " + p2 + "), wall case: " + wallCase + "\n");
  t2 = millis();
   
  // -------------------------------------------------------------------------------------------------
  // Part 3: Simulate the ball motion
     
  // Compute the new positions and velocities in the given frame
  if(animating && !stop && !stopForever) {
    P.advectBalls(mv); 
    P.resetColors(cyan); 
    P.bounceBalls(w);
    motionTime += mv;
  }

  t3 = millis();
   
   // -------------------------------------------------------------------------------------------------
   // Part 4: Display the balls, velocities, text, etc.
   
   P.showBalls(); 
   if(showV) P.showVelocities(br*2); 
   pt Picked = pick( mouseX, mouseY);
   if(picking) {P.pickClosestTo(Picked); picking=false;}
   P.showPickedBall();
  
   fill(blue); show(Picked,3); fill(red,100); showShadow(Picked,5,-w/2);  // show picked point and its shadow
   
   popMatrix(); // done with 3D drawing. Restore front view for writing text on canvas
  
  if(scribeText) {fill(black); displayHeader();} // dispalys header on canvas, including my face
  if(scribeText && !filming) displayFooter(); // shows menu at bottom, only if not filming
  if (animating) { // periodic change of time 
    animationTime+=PI/180/2; 
    if(animationTime>=TWO_PI) 
      animationTime=0; 
    s=(cos(animationTime)+1.)/2; 
  }  
  t4 = millis();
  if(!stop) {
    dt01=(t1-t0)/10/frameTime; 
    dt12=(t2-t1)/10/frameTime; 
    dt23=(t3-t2)/10/frameTime; 
    dt34=(t4-t3)/10/frameTime;
  }
  scribe("nbs = "+nbs+", "+(nbs*nbs*nbs)+" balls, "+nf(collisions,3,0)+" collisions per frame",10,40); 
  scribe("dt01 = "+nf(dt01,2,1)+"%, dt12 = "+nf(dt12,2,1)+"%, dt23 = "+nf(dt23,2,1)+"%, dt34 = "+nf(dt34,2,1)+"%",10,60); 
  if(filming && (animating || change)) 
    saveFrame("FRAMES/F"+nf(frameCounter++,4)+".png");  // save next frame to make a movie

  if((t4-t0)/10/frameTime>99 || stop) {
    scribe("dt01 = "+nf(dt01,2,1)+"%, dt12 = "+nf(dt12,2,1)+"%, dt23 = "+nf(dt23,2,1)+"%, dt34 = "+nf(dt34,2,1)+"%. STOPPED !",10,80); 
    stop=true;
    }
  change=false; // to avoid capturing frames when nothing happens (change is set uppn action)
  
  
  if((motionTime + mv) > firstCollisionTime) stopForever = true; 
  
}

/* *************************************************************************************************************************************************/
void keyPressed() {
  if(key=='`') picking=true; 
  if(key=='?') scribeText=!scribeText;
  if(key=='!') snapPicture();
  if(key=='~') filming=!filming;
  if(key=='x' || key=='/') stop=!stop;
  if(key=='v') showV=!showV;
  
  // Stop animation when two balls collide (see balls.pde)
  if(key=='I') individual=!individual;
  
  if(key=='i') {
    P.initPointsOnGrid(nbs,w,br,cyan); 
    stop=false;
    stopForever = false;
    firstCollisionTime = 10000000; // for the individual part of the project
    collisionTimeSet = false;
    motionTime = 0.0;
  }
  if(key=='a') {
    animating=!animating; // toggle animation
    stopForever = false;
  }
  
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
  //if(key=='x' || key=='z' || key=='d') P.setPickedTo(pp); // picks the vertex of P that has closest projeciton to mouse
  if(key=='d') P.deletePicked();
 // if(key=='i') P.insertClosestProjection(Of); // Inserts new vertex in P that is the closeset projection of O   //< the letter 'i' is used above!
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
    image(myFace, width-myFace.width/2,25,myFace.width/2,myFace.height/2); 
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