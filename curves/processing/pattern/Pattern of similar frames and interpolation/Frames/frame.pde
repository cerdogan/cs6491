FR F0 = F(), F1 = F(), F1rF0, E0, E0rF0, F, E, Ft, Et, Fk;
int k=7;
FR F() {return new FR();}
FR F(pt A, pt B) {return new FR(A,B);}
FR F(vec I, vec J, pt O) {return new FR(I,J, O);}
FR F(vec I, pt O) {vec J = R(I); return new FR(I,J, O);}
FR F(FR F) {return F(F.I,F.J,F.O);}
FR F(FR F0, float t, FR F1) {
  float a = angle(F0.I,F1.I); 
  float s = n(F1.I)/n(F0.I);
  pt G = spiralCenter(a,s,F0.O,F1.O); show(G,5);
  vec I = S(pow(s,t),R(F0.I,t*a));
  pt O = P(G,pow(s,t),R(V(G,F0.O),t*a)); 
  return F(I,O); 
  }

void showArrow(FR F) {F.showArrow();}
void showArrows(FR F) {F.showArrows();}

class FR { 
  pt O; vec I; vec J; 
  FR () {O=P(); I=V(1,0); J=V(0,1);}
  FR(vec II, vec JJ, pt OO) {I=V(II); J=V(JJ); O=P(OO);}
  FR(pt A, pt B) {O=P(A); I=V(A,B); J=R(I);}
  vec of(vec V) {return W(V.x,I,V.y,J);}
  pt of(pt P) {return P(O,W(P.x,I,P.y,J));}
  FR of(FR F) {return F(of(F.I),of(F.J),of(F.O));}
  vec invertedOf(vec V) {return V(det(V,J)/det(I,J),det(V,I)/det(J,I));}
  pt invertedOf(pt P) {vec V = V(O,P); return P(det(V,J)/det(I,J),det(V,I)/det(J,I));}
  FR invertedOf(FR F) {return F(invertedOf(F.I),invertedOf(F.J),invertedOf(F.O));}
  FR showArrow() {show(O,4); arrow(O,I); return this;}
  FR showArrows() {show(O,4); arrow(O,I); arrow(O,J); return this; }
  }