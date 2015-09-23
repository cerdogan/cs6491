//************************************************************************
//**** SPIRAL
//************************************************************************
pt PtOnSpiral(pt A, pt B, pt C, float t) {
  float a =spiralAngle(A,B,B,C); 
  float s =spiralScale(A,B,B,C);
  pt G = spiralCenter(a, s, A, B); 
  return L(G,R(B,t*a,G),pow(s,t));
  }

pt spiralPt(pt A, pt G, float s, float a) {return L(G,R(A,a,G),s);}  
pt spiralPt(pt A, pt G, float s, float a, float t) {return L(G,R(A,t*a,G),pow(s,t));} 
pt spiralCenter(pt A, pt B, pt C, pt D) { // computes center of spiral that takes A to C and B to D
  float a = spiralAngle(A,B,C,D); 
  float z = spiralScale(A,B,C,D);
  return spiralCenter(a,z,A,C);
  }
float spiralAngle(pt A, pt B, pt C, pt D) {return angle(V(A,B),V(C,D));}
float spiralScale(pt A, pt B, pt C, pt D) {return d(C,D)/d(A,B);}
pt spiralCenter(float a, float z, pt A, pt C) {
  float c=cos(a), s=sin(a);
  float D = sq(c*z-1)+sq(s*z);
  System.out.println("a: " + a + "z: " + z + ", c: " + c + ", z: " + z + ", D: " + D);
  float ex = c*z*A.x - C.x - s*z*A.y;
  float ey = c*z*A.y - C.y + s*z*A.x;
  float x=(ex*(c*z-1) + ey*s*z) / D;
  float y=(ey*(c*z-1) - ex*s*z) / D;
  return P(x,y);
  }
  
  