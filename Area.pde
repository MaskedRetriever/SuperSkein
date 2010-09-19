// SSArea class
import java.awt.geom.Area;

class SSArea extends Area {
  float GridScale;
  float HeadSpeed;
  float FlowRate;

  void SSArea() {
    GridScale=0.01;
    HeadSpeed=1000;
    FlowRate=0;
  }
  
  void setGridScale(float aGridScale) {
    GridScale=aGridScale;
  }
  float getGridScale() {
    return(GridScale);
  }

  void setHeadSpeed(float aHeadSpeed) {
    HeadSpeed=aHeadSpeed;
  }
  float getHeadSpeed() {
    return(HeadSpeed);
  }

  void setFlowRate(float aFlowRate) {
    FlowRate=aFlowRate;
  }
  float getFlowRate() {
    return(FlowRate);
  }

  void Slice2Area(Slice thisSlice) {
    SSPoly path2polys = new SSPoly();
    path2polys.setGridScale(GridScale);
    ArrayList PolyList = path2polys.Path2Polys(thisSlice.SlicePath);
    for(int i=0;i<PolyList.size();i++) {
      SSPoly thisPoly=(SSPoly) PolyList.get(i);
      this.exclusiveOr(new Area((Polygon) thisPoly));
    }
    AffineTransform scaleAreaTransform = new AffineTransform();
    scaleAreaTransform.setToScale(GridScale,GridScale);
    this.transform(scaleAreaTransform);
  }

  void makeShell(float shellWidth, int dirCount) {
    float sqt2=sqrt(2);
    AffineTransform shiftTrans = new AffineTransform();
    Area innerArea=new Area(this);
    for(int i=0;i<dirCount;i++) {
      float dx=shellWidth*cos(i*360/dirCount);
      float dy=shellWidth*sin(i*360/dirCount);
      shiftTrans.setToTranslation(dx,dy);
      Area shiftCopy = this.createTransformedArea(shiftTrans);
      shiftCopy.subtract(this);
      shiftTrans.setToTranslation(-dx,-dy); shiftCopy.transform(shiftTrans);
      if(shiftCopy.isEmpty()) println("  makeShell: shiftCopy is Empty");
      innerArea.subtract(shiftCopy);
    }
    if(innerArea.isEmpty()) {
      println(" makeShell: innerArea is Empty");
    } else {
      this.subtract(innerArea);
    }
  }
}
