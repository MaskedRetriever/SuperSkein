// SSPoly extends Polygon

import java.awt.Polygon;

class SSPoly extends Polygon {
  float GridScale;
  float HeadSpeed;
  float Flowrate;
  boolean debugFlag;

  SSPoly() {
    GridScale=0.01;
    HeadSpeed=1000;
    Flowrate=0;
    debugFlag=false;
  }

  void setGridScale(float aFloat) {
    GridScale=aFloat;
  }
  float getGridScale() {
    return(GridScale);
  }

  void setHeadSpeed(float aFloat) {
    HeadSpeed=aFloat;
  }
  float getHeadSpeed() {
    return(HeadSpeed);
  }

  void setFlowrate(float aFloat) {
    Flowrate=aFloat;
  }
  float getFlowrate() {
    return(Flowrate);
  }

  void setDebugFlag(boolean aBool) {
    debugFlag=aBool;
  }
  boolean getDebugFlag() {
    return(debugFlag);
  }

  void addPoint(float fx, float fy) {
    float scalefx=round(fx/GridScale);
    float scalefy=round(fy/GridScale);
    addPoint((int)scalefx,(int)scalefy);
  }

  boolean contains(float fx, float fy) {
    float scalefx=round(fx/GridScale);
    float scalefy=round(fy/GridScale);
    boolean bContains = contains((int)scalefx,(int)scalefy);
    return(bContains);
  }

  void translate(float fx, float fy) {
    float scalefx=round(fx/GridScale);
    float scalefy=round(fy/GridScale);
    translate((int)scalefx,(int)scalefy);
  }

  ArrayList Path2Polys(SSPath thisPath) {
    ArrayList returnList=new ArrayList();
    SSPoly thisPoly=new SSPoly();
    thisPoly.setDebugFlag(debugFlag);
    thisPoly.setGridScale(GridScale);
    returnList.add(thisPoly);
    PathIterator pathIter=thisPath.getPathIterator(new AffineTransform());
    float[] newCoords={0.0,0.0,0.0,0.0,0.0,0.0};
    float[] prevCoords={0.0,0.0,0.0,0.0,0.0,0.0};
    float[] startCoords={0.0,0.0,0.0,0.0,0.0,0.0};
    int segType=pathIter.currentSegment(prevCoords);
    segType=pathIter.currentSegment(startCoords);
    pathIter.next();
    while(!pathIter.isDone()) {
      segType=pathIter.currentSegment(newCoords);
      if(segType == PathIterator.SEG_LINETO ) {
        if(debugFlag) print(".");
	thisPoly.addPoint(prevCoords[0],prevCoords[1]);
        segType=pathIter.currentSegment(prevCoords);
      } else if( segType==PathIterator.SEG_CLOSE) {
        if(debugFlag) println("\n  Polygon: "+returnList.size()+"  SEG_CLOSE: "+newCoords[0]+" "+newCoords[1]);
	thisPoly.addPoint(prevCoords[0],prevCoords[1]);
        segType=pathIter.currentSegment(prevCoords);
      } else if(segType == PathIterator.SEG_MOVETO) {
        if(debugFlag) println("\n  Polygon: "+returnList.size()+"  SEG_MOVETO: "+newCoords[0]+" "+newCoords[1]);
	thisPoly=new SSPoly();
        thisPoly.setDebugFlag(debugFlag);
        thisPoly.setGridScale(GridScale);
	returnList.add(thisPoly);
        segType=pathIter.currentSegment(prevCoords);
        segType=pathIter.currentSegment(startCoords);
      } else {
        println("  Polygon: "+returnList.size()+"  segType: "+segType+"\n");
        segType=pathIter.currentSegment(prevCoords);
      }
      pathIter.next();
    }
    if(debugFlag) println(" SSPoly Count: "+returnList.size()+"\n");
    return(returnList);
  }


}
