// Fill Generation
import java.awt.geom.Rectangle2D;

class Fill {

  boolean debugFlag;
  int Width;
  int Height;
  Extruder ExtruderProperties;
  float SparseFillDensity;
  float RotateFillAngle;
  SSArea SparseFill;
  SSArea BridgeFill;

  Fill(boolean bFlag, int iWidth, int iHeight, float fillDensity) {
    RotateFillAngle=45.0;
    debugFlag=bFlag;
    Width=iWidth;
    Height=iHeight;
    if(fillDensity<0 || fillDensity>1.0) {
      println("Sparse Fill Density out of 0 to 1.0 range. Setting to 0.5");
      SparseFillDensity=0.5;
    } else {
      SparseFillDensity=fillDensity;
    }
    ExtruderProperties = new Extruder();
    SparseFill = new SSArea();
    SparseFill.setGridScale(0.01);
    float wallWidth=ExtruderProperties.calcWallWidth();
    for(float dx=0;dx<2*Width; dx+=2*wallWidth/fillDensity) {
      Rectangle2D thisRect=new Rectangle2D.Float(dx,0,wallWidth/fillDensity,2*Height);
      Area thisRectArea=new Area(thisRect);
      AffineTransform centerAreaTransform = new AffineTransform();
      centerAreaTransform.setToTranslation(-Width,-Height);
      thisRectArea.transform(centerAreaTransform);
      SparseFill.add(thisRectArea);
    }
    BridgeFill = new SSArea();
    BridgeFill.setGridScale(0.01);
    for(float dx=0;dx<2*Width; dx+=2*wallWidth) {
      Rectangle2D thisRect=new Rectangle2D.Float(dx,0,wallWidth,2*Height);
      Area thisRectArea=new Area(thisRect);
      AffineTransform centerAreaTransform = new AffineTransform();
      centerAreaTransform.setToTranslation(-Width,-Height);
      thisRectArea.transform(centerAreaTransform);
      BridgeFill.add(thisRectArea);
    }
  }

  ArrayList GenerateFill(ArrayList SliceList) {
    ArrayList FillAreaList = new ArrayList();
    float wallWidth=ExtruderProperties.calcWallWidth();
    for(int LayerNum=0; LayerNum<SliceList.size();LayerNum++) {
      SSArea thisArea = (SSArea) SliceList.get(LayerNum);
      // Shell area to subtract off slice.
      SSArea thisShell = new SSArea();
      thisShell.setGridScale(thisArea.getGridScale());
      thisShell.add(thisArea);
      thisShell.makeShell(wallWidth,8);
      // Fill mask area
      SSArea thisFill = new SSArea();
      thisFill.setGridScale(thisArea.getGridScale());
      thisFill.add(thisArea);
      thisFill.subtract(thisShell);
      // Identify bridge areas for special treatment.
      SSArea thisBridge = new SSArea();
      thisBridge.setGridScale(thisFill.getGridScale());
      thisBridge.add(thisFill);
      AffineTransform rotateFill = new AffineTransform();
      rotateFill.setToRotation(2*PI*RotateFillAngle/360.0);
      BridgeFill.transform(rotateFill);
      SparseFill.transform(rotateFill);
      if(LayerNum==0 || LayerNum==SliceList.size()-1) {
	// Bottom and Top layer special case.
	thisFill.intersect(BridgeFill);
      } else {
	SSArea prevArea = (SSArea) SliceList.get(LayerNum-1);
	thisBridge.subtract(prevArea);
	// Identify cap areas for special treatment.
	SSArea nextArea = (SSArea) SliceList.get(LayerNum+1);
	SSArea thisCap = new SSArea();
	thisCap.setGridScale(thisFill.getGridScale());
	thisCap.add(thisArea);
	thisCap.subtract(nextArea);
	thisBridge.add(thisCap);
	if(!thisBridge.isEmpty()) {
	  thisFill.subtract(thisBridge);
	  thisBridge.intersect(BridgeFill);
	  thisFill.intersect(SparseFill);
	  thisFill.add(thisBridge);
	} else {
	  thisFill.intersect(SparseFill);
	}
      }
      // Subtract bridge areas from fill mask
      FillAreaList.add(LayerNum,thisFill);
    }
    return(FillAreaList);
  }
}

