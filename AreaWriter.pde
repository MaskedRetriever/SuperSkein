// Class to write Areas out to DXF and other formats.
import processing.dxf.*;

class AreaWriter {

  boolean debugFlag;
  int Width;
  int Height;

  float OperatingTemp;
  float FlowRate;
  float LayerThickness;
  float PrintHeadSpeed;

  PrintWriter GCodeOutput;
  RawDXF DXFOutput;

  AreaWriter(boolean bFlag, int iWidth, int iHeight) {
    debugFlag=bFlag;
    Width=iWidth;
    Height=iHeight;
  }

  void setOperatingTemp(float aFloat) {
    OperatingTemp=aFloat;
  }
  void setFlowRate(float aFloat) {
    FlowRate=aFloat;
  }
  void setLayerThickness(float aFloat) {
    LayerThickness=aFloat;
  }
  void setPrintHeadSpeed(float aFloat) {
    PrintHeadSpeed=aFloat;
  }

  void ArrayList2DXF(String FileName, ArrayList AreaList) {
    DXFOutput=(RawDXF) createGraphics(round(Width),round(Height),DXF,FileName);
    beginRaw(DXFOutput);
    for(int SliceNum=0;SliceNum<AreaList.size();SliceNum++) {
      DXFOutput.setLayer(SliceNum);
      SSArea thisArea=(SSArea) AreaList.get(SliceNum);
      PathIterator pathIter=thisArea.getPathIterator(new AffineTransform());
      float[] newCoords={0.0,0.0,0.0,0.0,0.0,0.0};
      float[] prevCoords={0.0,0.0,0.0,0.0,0.0,0.0};
      float[] startCoords={0.0,0.0,0.0,0.0,0.0,0.0};
      int segType=pathIter.currentSegment(prevCoords);
      segType=pathIter.currentSegment(startCoords);
      pathIter.next();
      while(!pathIter.isDone()) {
        segType=pathIter.currentSegment(newCoords);
        if(segType == PathIterator.SEG_LINETO ) {
          // println("  SEG_LINETO: "+newCoords[0]+" "+newCoords[1]+"\n");
          if(debugFlag) print(".");
          DXFOutput.line(prevCoords[0],prevCoords[1],newCoords[0],newCoords[1]);
          segType=pathIter.currentSegment(prevCoords);
        } else if( segType==PathIterator.SEG_CLOSE) {
          if(debugFlag) println("\n  Slice: "+SliceNum+"  SEG_CLOSE: "+newCoords[0]+" "+newCoords[1]);
          // DXFOutput.line(prevCoords[0],prevCoords[1],newCoords[0],newCoords[1]);
          DXFOutput.line(newCoords[0],newCoords[1],startCoords[0],startCoords[1]);
          segType=pathIter.currentSegment(prevCoords);
        } else if(segType == PathIterator.SEG_MOVETO) {
          if(debugFlag) println("\n  Slice: "+SliceNum+"  SEG_MOVETO: "+newCoords[0]+" "+newCoords[1]);
          segType=pathIter.currentSegment(prevCoords);
          segType=pathIter.currentSegment(startCoords);
        } else {
          println("\n  Slice: "+SliceNum+"  segType: "+segType);
          segType=pathIter.currentSegment(prevCoords);
        }
        pathIter.next();
      }
    }
    endRaw();
  }

  void GCodeInit(String aString) {
    GCodeOutput = createWriter(aString);
  }

  void GCodeWriteHeader() {
    GCodeOutput.println("G21");
    GCodeOutput.println("G90");
    GCodeOutput.println("M103");
    GCodeOutput.println("M105");
    GCodeOutput.println("M104 s"+OperatingTemp);
    GCodeOutput.println("M109 s"+FlowRate);
    GCodeOutput.println("M101");
  }

  void GCodeWriteFooter() {
    GCodeOutput.flush();
    GCodeOutput.close();
  }

  void GCodeWriteArea(int SliceNum, SSArea thisArea) {
    PathIterator pathIter=thisArea.getPathIterator(new AffineTransform());
    float[] newCoords={0.0,0.0,0.0,0.0,0.0,0.0};
    float[] prevCoords={0.0,0.0,0.0,0.0,0.0,0.0};
    float[] startCoords={0.0,0.0,0.0,0.0,0.0,0.0};
    int segType=pathIter.currentSegment(startCoords);
    // Move to starting point
    GCodeOutput.println("M103");
    GCodeOutput.println("G1 X" + startCoords[0] + " Y" + startCoords[1] + " Z" + SliceNum*LayerThickness + " F" + PrintHeadSpeed);
    GCodeOutput.println("M101");
    segType=pathIter.currentSegment(prevCoords);
    pathIter.next();
    while(!pathIter.isDone()) {
      segType=pathIter.currentSegment(newCoords);
      if(segType == PathIterator.SEG_LINETO ) {
        // draw line from prevCoords to newCoords
        GCodeOutput.println("G1 X" + newCoords[0] + " Y" + newCoords[1] + " Z" + SliceNum*LayerThickness + " F" + PrintHeadSpeed);
        segType=pathIter.currentSegment(prevCoords);
      } else if(segType==PathIterator.SEG_CLOSE ) {
        // last segment of current path
        GCodeOutput.println("G1 X" + newCoords[0] + " Y" + newCoords[1] + " Z" + SliceNum*LayerThickness + " F" + PrintHeadSpeed);
        GCodeOutput.println("G1 X" + startCoords[0] + " Y" + startCoords[1] + " Z" + SliceNum*LayerThickness + " F" + PrintHeadSpeed);
        segType=pathIter.currentSegment(prevCoords);
      } else if(segType==PathIterator.SEG_MOVETO ) {
        // move to next starting point
        segType=pathIter.currentSegment(prevCoords);
        GCodeOutput.println("M103");
        GCodeOutput.println("G1 X" + newCoords[0] + " Y" + newCoords[1] + " Z" + SliceNum*LayerThickness + " F" + PrintHeadSpeed);
        GCodeOutput.println("M101");
        segType=pathIter.currentSegment(prevCoords);
        segType=pathIter.currentSegment(startCoords);
      } else {
        // unknown segment type
        segType=pathIter.currentSegment(prevCoords);
      }
      pathIter.next();
    }
    GCodeOutput.println("M103");
  }

  void GCodeWriteModel(ArrayList SliceAreaList, ArrayList ShellAreaList, ArrayList FillAreaList) {
    for(int SliceNum=0;SliceNum<SliceAreaList.size();SliceNum++)
    {
      SSArea thisArea;
      //if(ShellAreaList.size()>0) {
      //  thisArea = (SSArea) ShellAreaList.get(SliceNum);
      //  if(!thisArea.isEmpty()) GCodeWriteArea(SliceNum, thisArea);
      //}
      if(FillAreaList.size()>0) {
        thisArea = (SSArea) FillAreaList.get(SliceNum);
        if(!thisArea.isEmpty()) GCodeWriteArea(SliceNum, thisArea);
      }
      if(SliceAreaList.size()>0) {
        thisArea = (SSArea) SliceAreaList.get(SliceNum);
        if(!thisArea.isEmpty()) GCodeWriteArea(SliceNum, thisArea);
      }
    }
  }

  void ArrayList2GCode(String FileName, ArrayList SliceAreaList, ArrayList ShellAreaList, ArrayList FillAreaList) {
    GCodeInit(FileName);
    GCodeWriteHeader();
    GCodeWriteModel(SliceAreaList,ShellAreaList,FillAreaList);
    GCodeWriteFooter();  
  }

}

