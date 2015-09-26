//************************************************************************
//**** CIRCLES
//************************************************************************
// create 
float circumRadius (pt A, pt B, pt C) {float a=d(B,C), b=d(C,A), c=d(A,B), s=(a+b+c)/2, d=sqrt(s*(s-a)*(s-b)*(s-c)); return a*b*c/4/d;} // radiusCircum(A,B,C): radius of circumcenter
pt CircumCenter (pt A, pt B, pt C) {vec AB = V(A,B); vec AC = R(V(A,C)); 
   return P(A,1./2/dot(AB,AC),W(-n2(AC),R(AB),n2(AB),AC)); }; // CircumCenter(A,B,C): center of circumscribing circle, where medians meet)

// display 
void drawCircle(int n) {  
  float x=1, y=0; float a=TWO_PI/n, t=tan(a/2), s=sin(a); 
  beginShape(); for (int i=0; i<n; i++) {x-=y*t; y+=x*s; x-=y*t; vertex(x,y);} endShape(CLOSE);}


void showArcThrough (pt A, pt B, pt C) {
  if (abs(dot(V(A,B),R(V(A,C))))<0.01*d2(A,C)) {edge(A,C); return;}
   pt O = CircumCenter ( A,  B,  C); 
   float r=d(O,A);
   vec OA=V(O,A), OB=V(O,B), OC=V(O,C);
   float b = angle(OA,OB), c = angle(OA,OC); 
   if(0<c && c<b || b<0 && 0<c)  c-=TWO_PI; 
   else if(b<c && c<0 || c<0 && 0<b)  c+=TWO_PI; 
   beginShape(); v(A); for (float t=0; t<1; t+=0.01) v(R(A,t*c,O)); v(C); endShape();
   }

pt pointOnArcThrough (pt A, pt B, pt C, float t) { // July 2011
  if (abs(dot(V(A,B),R(V(A,C))))<0.001*d2(A,C)) {edge(A,C); return L(A,C,t);}
   pt O = CircumCenter ( A,  B,  C); 
   float r=(d(O,A) + d(O,B)+ d(O,C))/3;
   vec OA=V(O,A), OB=V(O,B), OC=V(O,C);
   float b = angle(OA,OB), c = angle(OA,OC); 
   if(0<b && b<c) {}
   else if(0<c && c<b) {b=b-TWO_PI; c=c-TWO_PI;}
   else if(b<0 && 0<c) {c=c-TWO_PI;}
   else if(b<c && c<0) {b=TWO_PI+b; c=TWO_PI+c;}
   else if(c<0 && 0<b) {c=TWO_PI+c;}
   else if(c<b && b<0) {}
   return R(A,t*c,O);
   }
