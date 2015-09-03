int pp=1; // index of picked vertex
BALLS P = new BALLS(); // polyloop in 3D
BALLS Q = new BALLS(); // second polyloop in 3D
BALLS PtQ = new BALLS(); // inbetweening polyloop L(P,t,Q);
int del = 5; // delay fo rcolors to stay after collision

class BALLS { // class for manipulaitng and displaying points
 Boolean loop=true;
 int pv =0, // index of picked ball
     iv=0, //  insertion vertex index
     nv = 0;  // number of vertices currently used in P
 int maxnv = 16000;                 //  max number of vertices
 pt[] G = new pt [maxnv];           // ball centers
 vec[] V = new vec [maxnv];         // velocities
 float[] r = new float [maxnv];     // radii
 color[] c = new color [maxnv];     // colors
 int[] m = new int [maxnv];         // delay before resetting color
 
  BALLS() {}
 
  BALLS declare() {for (int i=0; i<maxnv; i++) {G[i]=P(); V[i]=V(); r[i]=1; c[i]=yellow; m[i]=0;}return this;}     // init all point objects
  
  void initPointsOnGrid(int nb, float w, float r, color c) { // number of BALLS in each dimension, distance between them 
    empty();
    float d = w / (nb+1), dd=d;
    for (int i=0; i<nb; i++) 
      for (int j=0; j<nb; j++) 
        for (int k=0; k<nb; k++)
          addBall(P(d*i-w/2+dd,d*j-w/2+dd,d*k-w/2+dd),V(random(-1,1),random(-1,1),random(-1,1)),r,c);
    }
    
  BALLS addBall(pt Pp, vec Vp, float rp, color cp) { 
    G[nv].setTo(Pp); 
    V[nv].setTo(Vp); 
    r[nv]=rp; 
    c[nv]=cp; 
    pv=nv; 
    nv++;  
    return this;} // adds a point at the end
    
  void showBalls() { noStroke(); for (int v=0; v<nv; v++) {fill(c[v]); show(G[v],r[v]); } }
  
  void showPickedBall() { noStroke(); fill(magenta); show(G[pv],r[pv]+1); } 
  
  void resetColors(color dc) { for (int v=0; v<nv; v++) if(m[v]>0) {m[v]--; if(m[v]==0) c[v]=dc;} }
  
  void showVelocities(float m) {noStroke(); fill(blue); for (int v=0; v<nv; v++) arrow(G[v],V(m,V[v]),3); }
  
  /* *************************************************************************************************************************************** */
  void advectBalls(float m) {
    for (int v=0; v<nv; v++) { 
      vec vel = V(m, V[v]);  // magnify the velocity V[v] with some constant m
      G[v]=P(G[v],vel);      // move the center of the particle by the velocity vector
    }
  }
  
  /* *************************************************************************************************************************************** */
  void bounceBalls(float w) {
    
    // Wall collisions: (1) generate new velocities, (2) change colors to green
    for (int v=0; v<nv; v++) {
      if(G[v].x<-w/2+r[v] || G[v].x>w/2-r[v]) {V[v].x=-V[v].x; c[v]=green; m[v]=del; if(individual) stop=true; collisions++;}
      if(G[v].y<-w/2+r[v] || G[v].y>w/2-r[v]) {V[v].y=-V[v].y; c[v]=green; m[v]=del; if(individual) stop=true; collisions++;}
      if(G[v].z<-w/2+r[v] || G[v].z>w/2-r[v]) {V[v].z=-V[v].z; c[v]=green; m[v]=del; if(individual) stop=true; collisions++;}
    }
    
    // Ball-ball collisions: only change colors to red
    for (int u=0; u<nv-1; u++) { 
      for (int v=u+1; v<nv; v++) { 
        if(d(G[u],G[v])<r[u]+r[v]) {
            c[u]=red; 
            m[u]=del; 
            c[v]=red; 
            m[v]=del; 
            if(individual) stop=true;
            collisions++;
        }
      }
    }
  }
    
  /* *************************************************************************************************************************************** */
  BALLS empty() {nv=0; pv=0; return this;} // resets P so that we can start adding points
  BALLS addPt(pt P) { G[nv].setTo(P); pv=nv; nv++;  return this;} // adds a point at the end
  BALLS addPt(float x,float y) { G[nv].x=x; G[nv].y=y; pv=nv; nv++; return this;}
  BALLS copyFrom(BALLS Q) {empty(); nv=Q.nv; for (int v=0; v<nv; v++) G[v]=P(Q.G[v]); return this;}
  BALLS setToL(BALLS P, float t, BALLS Q) { // lerp (linear interpolation betwen P and Q
    empty(); 
    nv=min(P.nv,Q.nv); 
    for (int v=0; v<nv; v++) G[v]=L(P.G[v],t,Q.G[v]); 
    return this;}
  BALLS resetOnCircle(int k, float r) { // makes new polyloo[p with k  points on a circle around origin
    empty(); // resert P
    pt C = P(); // center of circle
    for (int i=0; i<k; i++) addPt(R(P(C,V(0,-r,0)),2.*PI*i/k,C)); // points on z=0 plane
    pv=0; // picked vertex ID is set to 0
    return this;
    } 
  int idOfVertexWithClosestScreenProjectionTo(pt M) { // for picking a vertex with the mouse
    pp=0; 
    for (int i=1; i<nv; i++) if (d(M,ToScreen(G[i]))<=d(M,ToScreen(G[pp]))) pp=i; 
    return pp;
    }
    
  pt closestProjectionOf(pt M) {   // for picking inserting O. Returns projection but also CHANGES iv !!!!
    pt C = P(G[0]); float d=d(M,C);       
    for (int i=1; i<nv; i++) if (d(M,G[i])<=d) {iv=i; C=P(G[i]); d=d(M,C); }  
    for (int i=nv-1, j=0; j<nv; i=j++) { 
       pt A = G[i], B = G[j];
       if(projectsBetween(M,A,B) && disToLine(M,A,B)<d) {d=disToLine(M,A,B); iv=i; C=projectionOnLine(M,A,B);}
       } 
    return C;    
    }
    
  void pickClosestTo(pt M) {   // for picking inserting O. Returns projection but also CHANGES iv !!!!
    pt C = P(G[0]); float d=d(M,C);       
    for (int i=1; i<nv; i++) if (d(M,G[i])<=d) {pv=i; C=P(G[i]); d=d(M,C); }  
    }
    
  BALLS insertPt(pt P) { // inserts new vertex after vertex with ID iv
    for(int v=nv-1; v>iv; v--) G[v+1].setTo(G[v]); 
     iv++; 
     G[iv].setTo(P);
     nv++; // increments vertex count
     return this;
     }
  BALLS insertClosestProjection(pt M) {  
    pt P = closestProjectionOf(M); // also sets iv
    insertPt(P);
    return this;
    }

  BALLS deletePicked() {for(int i=pv; i<nv; i++) G[i].setTo(G[i+1]); pv=max(0,pv-1); nv--;  return this;}
  BALLS setPt(pt P, int i) { G[i].setTo(P); return this;}
  BALLS showPicked() {show(G[pv],13); return this;}
  BALLS drawBalls(float r) {for (int v=0; v<nv; v++) show(G[v],r); return this;}
  BALLS showPicked(float r) {show(G[pv],r); return this;}
  BALLS drawClosedCurve(float r) {for (int v=0; v<nv-1; v++) stub(G[v],V(G[v],G[v+1]),r,r/2);  stub(G[nv-1],V(G[nv-1],G[0]),r,r/2); return this;}
  BALLS setPickedTo(int pp) {pv=pp; return this;}
  BALLS movePicked(vec V) { G[pv].add(V); return this;}      // moves selected point (index p) by amount mouse moved recently
  BALLS moveAll(vec V) {for (int i=0; i<nv; i++) G[i].add(V); return this;};   
  pt Picked() {return G[pv];} 

void saveBALLS(String fn) {
  String [] inpBALLS = new String [nv+1];
  int s=0;
  inpBALLS[s++]=str(nv);
  for (int i=0; i<nv; i++) {inpBALLS[s++]=str(G[i].x)+","+str(G[i].y)+","+str(G[i].z);}
  saveStrings(fn,inpBALLS);
  };
  
void loadBALLS(String fn) {
  println("loading: "+fn); 
  String [] ss = loadStrings(fn);
  String subBALLS;
  int s=0;   int comma, comma1, comma2;   float x, y;   int a, b, c;
  nv = int(ss[s++]); print("nv="+nv);
  for(int k=0; k<nv; k++) {int i=k+s; float [] xy = float(split(ss[i],",")); G[k].setTo(xy[0],xy[1],xy[2]);}
  pv=0;
  }; 

} // end of BALLS class