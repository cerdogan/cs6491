// LecturesInGraphics: utilities
// Author: Jarek ROSSIGNAC, last edited on July 21, 2015 
import processing.pdf.*;    // to save screen shots as PDFs
PImage myFace; // picture of author's face, should be: data/pic.jpg in sketch folder

// ************************************************************************ COLORS 
color black=#000000, white=#FFFFFF, // set more colors using Menu >  Tools > Color Selector
   red=#FF0000, green=#00FF01, blue=#0300FF, yellow=#FEFF00, cyan=#00FDFF, magenta=#FF00FB, grey=#5F5F5F, brown=#AF6407,
   sand=#FCBA69, pink=#FF8EE7 ;
// ************************************************************************ GRAPHICS 
void pen(color c, float w) {stroke(c); strokeWeight(w); noFill();}
void pen(color c, float w, color f) {stroke(c); strokeWeight(w); fill(f);}
void penFill(color c, float w) {stroke(c); strokeWeight(w); fill(c);}
void showDisk(float x, float y, float r) {ellipse(x,y,r*2,r*2);}

// ************************************************************************ SAVING INDIVIDUAL IMAGES OF CANVAS 
boolean snapPic=false;
String PicturesOutputPath="data/PDFimages";
int pictureCounter=0;
void snapPicture() {saveFrame("PICTURES/P"+nf(pictureCounter++,3)+".jpg"); }

//************************ SAVING IMAGES for a MOVIE
boolean filming=false;  // when true frames are captured in FRAMES for a movie
int frameCounter=0;     // count of frames captured (used for naming the image files)
boolean change=false;   // true when the user has presed a key or moved the mouse
boolean animating=false; // must be set by application during animations to force frame capture
/*
To make a movie : 
Press '~' to start filming, 
act the movie or start an animation, 
press '~' to pause/stop (you can restart to add frames)
Then, from within your Processing sketch, 
from the processing menu, select Tools > Movie Maker. 
Click on Choose… Navigate to your Sketch Folder. 
Select, but do not open, the FRAMES folder.
Press Create Movie, 
Select the parameters you want. 

May not work for a large canvas!
*/

// ************************************************************************ TEXT 
Boolean scribeText=true; // toggle for displaying of help text
void scribe(String S, float x, float y) {fill(0); text(S,x,y); noFill();} // writes on screen at (x,y) with current fill color
void scribeHeader(String S, int i) { text(S,10,20+i*20); noFill();} // writes black at line i
void scribeHeaderRight(String S) {fill(0); text(S,width-7.5*S.length(),20); noFill();} // writes black on screen top, right-aligned
void scribeFooter(String S, int i) {fill(0); text(S,10,height-10-i*20); noFill();} // writes black on screen at line i from bottom
void scribeAtMouse(String S) {fill(0); text(S,mouseX,mouseY); noFill();} // writes on screen near mouse
void scribeMouseCoordinates() {fill(black); text("("+mouseX+","+mouseY+")",mouseX+7,mouseY+25); noFill();}
void displayHeader() { // Displays title and authors face on screen
    scribeHeader(title,0); scribeHeaderRight(name); 
    image(myFace, width-myFace.width/2,25,myFace.width/2,myFace.height/2); 
    }
void displayFooter() { // Displays help text at the bottom
    scribeFooter(guide,1); 
    scribeFooter(menu,0); 
    }