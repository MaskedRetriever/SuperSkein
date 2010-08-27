// Testing 2D boolean operation using Java built-in Area construct.
// - extending example from http://wiki.processing.org/w/Using_AWT's_Polygon_class
import java.awt.geom.AffineTransform;
import java.awt.geom.Area;
import java.awt.geom.PathIterator;
import java.awt.Polygon;

class Area2D extends Area{
  float gridScale;
  public Area2D(Poly2D p) {
    super( (Polygon) p );
    gridScale=p.gridScale;
  }
  public Area2D(float gScale) {
    super();
    gridScale=gScale;
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

  void drawMe(){
    PathIterator pathIter=getPathIterator(new AffineTransform());
    beginShape();
    float[] newCoords={0,0};
    while(!pathIter.isDone()) {
      pathIter.currentSegment(newCoords);
      vertex(gridScale*newCoords[0],gridScale*newCoords[1]);
      pathIter.next();
    }
    endShape();
  }
}

