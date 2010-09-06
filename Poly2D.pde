// Testing 2D boolean operation using Java built-in Area construct.
// - extending example from http://wiki.processing.org/w/Using_AWT's_Polygon_class

import java.awt.Polygon;

/*
 The class inherit all the fields, constructors and functions 
 of the java.awt.Polygon class, including contains(), xpoint,ypoint,npoint
*/
 
class Poly2D extends Polygon{
  float gridScale;
  float epsilon;
  
  public Poly2D(float gScale) {
    super();
    gridScale=gScale;
    epsilon=gridScale/2;
  }
  
  public Poly2D(float gScale, int[] x,int[] y, int n) {
    super();
    gridScale=gScale;
    epsilon=gridScale/2;
    //call the java.awt.Polygon addPoint function
    for(int i=0;i<n;i++) {
      super.addPoint((int) round(x[i]/gridScale),(int) round(y[i]/gridScale));
    }
  }

  public Poly2D(float gScale, double[] x,double[] y, int n) {
    super();
    gridScale=gScale;
    epsilon=gridScale/2;
    println("Area2D gridScale="+gridScale);
    //call the java.awt.Polygon addPoint function
    for(int i=0;i<n;i++) {
      super.addPoint((int) (x[i]/gridScale),(int) (y[i]/gridScale));
    }
  }

  void addPoint(float xf, float yf) {
    super.addPoint((int) (xf/gridScale), (int) (yf/gridScale));
  }

  ArrayList Slice2Poly2DList(Slice thisSlice) {
    ArrayList nuAL=new ArrayList();
    Poly2D nuP2D=new Poly2D(gridScale);
    SSLine prevLine=(SSLine) thisSlice.Lines.get(0);
    PVector startPt = prevLine.getPoint1();
    nuP2D.addPoint(startPt.x,startPt.y);
    for(int i = 1; i<thisSlice.Lines.size(); i++ ) {
      SSLine thisLine=(SSLine) thisSlice.Lines.get(i);
      PVector prevPt = prevLine.getPoint2(); 
      PVector currPt = thisLine.getPoint1();
      if(abs(prevPt.x-currPt.x)<epsilon && abs(prevPt.y-currPt.y)<epsilon) {
	nuP2D.addPoint(currPt.x,currPt.y);
      } else {
	nuP2D.addPoint(prevPt.x,prevPt.y);
	nuAL.add(nuP2D);
	nuP2D=new Poly2D(gridScale);
	nuP2D.addPoint(currPt.x,currPt.y);
	startPt=currPt;
      }
      if(abs(startPt.x-currPt.x)<epsilon && abs(startPt.y-currPt.y)<epsilon) {
        nuP2D.addPoint(currPt.x,currPt.y);
        i++;
	if(i<thisSlice.Lines.size()) {
          nuAL.add(nuP2D);
          nuP2D=new Poly2D(gridScale);
          prevLine=(SSLine) thisSlice.Lines.get(i);
          startPt=prevLine.getPoint1();
	  nuP2D.addPoint(startPt.x,startPt.y);
	} else {
	  PVector lastPt=thisLine.getPoint2();
	  nuP2D.addPoint(lastPt.x,lastPt.y);
          nuAL.add(nuP2D);
	}
      } else {
        prevLine=thisLine;
      }
    }
    return nuAL;
  }

  void translate(int x, int y) {
    super.translate((int) round(x/gridScale),(int) round(y/gridScale));
  }
  
  void translate(double x, double y) {
    super.translate((int) (x/gridScale),(int) (y/gridScale));
  }

  
  boolean contains(int x, int y) {
    double dx=x/gridScale;
    double dy=y/gridScale;
    return super.contains(dx,dy);
  }

  boolean contains(double x, double y) {
    double dx=x/gridScale;
    double dy=y/gridScale;
    return super.contains(dx,dy);
  }


  float getGrid() {
    return gridScale;
  }
 
  void drawMe(){
    beginShape();
    for(int i=0;i<npoints;i++){
      vertex(round(gridScale*xpoints[i]),round(gridScale*ypoints[i]));
    }
    endShape();
  }
}

