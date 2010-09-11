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

  void makeShell(float shellWidth) {
    float sqt2=sqrt(2);
    AffineTransform shiftTrans = new AffineTransform();
    
    shiftTrans.setToTranslation(shellWidth,0); Area copyXP = this.createTransformedArea(shiftTrans);
    copyXP.subtract(this);
    shiftTrans.setToTranslation(-shellWidth,0); copyXP.transform(shiftTrans);
    if(copyXP.isEmpty()) println("  makeShell: copyXP is Empty");
    
    shiftTrans.setToTranslation(-shellWidth,0); Area copyXM = this.createTransformedArea(shiftTrans);
    copyXM.subtract(this);
    shiftTrans.setToTranslation(shellWidth,0); copyXM.transform(shiftTrans);
    if(copyXM.isEmpty()) println("  makeShell: copyXM is Empty");
    
    shiftTrans.setToTranslation(0,shellWidth); Area copyYP = this.createTransformedArea(shiftTrans);
    copyYP.subtract(this);
    shiftTrans.setToTranslation(0,-shellWidth); copyYP.transform(shiftTrans);
    if(copyYP.isEmpty()) println("  makeShell: copyYP is Empty");
    
    shiftTrans.setToTranslation(0,-shellWidth); Area copyYM = this.createTransformedArea(shiftTrans);
    copyYM.subtract(this);
    shiftTrans.setToTranslation(0,shellWidth); copyYM.transform(shiftTrans);
    if(copyYM.isEmpty()) println("  makeShell: copyYM is Empty");

    // Diagonals
    shiftTrans.setToTranslation(shellWidth/sqt2,shellWidth/sqt2); Area copyXPYP = this.createTransformedArea(shiftTrans);
    copyXPYP.subtract(this);
    shiftTrans.setToTranslation(-shellWidth/sqt2,-shellWidth/sqt2); copyXPYP.transform(shiftTrans);
    if(copyXPYP.isEmpty()) println("  makeShell: copyXPYP is Empty");
    
    shiftTrans.setToTranslation(-shellWidth/sqt2,shellWidth/sqt2); Area copyXMYP = this.createTransformedArea(shiftTrans);
    copyXMYP.subtract(this);
    shiftTrans.setToTranslation(shellWidth/sqt2,-shellWidth/sqt2); copyXMYP.transform(shiftTrans);
    if(copyXM.isEmpty()) println("  makeShell: copyXMYP is Empty");
    
    shiftTrans.setToTranslation(shellWidth/sqt2,-shellWidth/sqt2); Area copyXPYM = this.createTransformedArea(shiftTrans);
    copyXPYM.subtract(this);
    shiftTrans.setToTranslation(-shellWidth/sqt2,shellWidth/sqt2); copyXPYM.transform(shiftTrans);
    if(copyXPYM.isEmpty()) println("  makeShell: copyXPYM is Empty");
    
    shiftTrans.setToTranslation(-shellWidth/sqt2,-shellWidth/sqt2); Area copyXMYM = this.createTransformedArea(shiftTrans);
    copyXMYM.subtract(this);
    shiftTrans.setToTranslation(shellWidth/sqt2,shellWidth/sqt2); copyXMYM.transform(shiftTrans);
    if(copyYM.isEmpty()) println("  makeShell: copyXMYM is Empty");

    
    Area innerArea=new Area(this);
    innerArea.subtract(copyXP);
    innerArea.subtract(copyXM);
    innerArea.subtract(copyYP);
    innerArea.subtract(copyYM);
    innerArea.subtract(copyXPYP);
    innerArea.subtract(copyXMYP);
    innerArea.subtract(copyXPYM);
    innerArea.subtract(copyXMYM);
    if(innerArea.isEmpty()) {
      println(" makeShell: innerArea is Empty");
    } else {
      this.subtract(innerArea);
    }
  }
}
