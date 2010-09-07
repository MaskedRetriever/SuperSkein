//SuperSkein!
//
//SuperSkein is an open source mesh slicer.
//Note!  Only takes binary-coded STL.  ASCII
//STL just breaks it for now.
import processing.dxf.*;
import java.awt.geom.PathIterator;

//The config file takes precedence over these parameters!

float PreScale = 1;
String FileName = "sculpt_dragon.stl";
float XRotate = 0;

String DXFSliceFilePrefix = "dxf_slice";

// Set DXFExportMode=1 to switch render and enable dependent code.
int DXFExportMode = 1;
// Set OpenSCADTestMode=1 to enable OpenSCAD test code.
int OpenSCADTestMode=0;

//Non-GUI-Reachable but in ~config.txt
float PrintHeadSpeed = 2000.0;
float LayerThickness = 0.3;
float Sink = 2.0;
int OperatingTemp = 220;
int FlowRate = 180;




//Display Properties
float BuildPlatformWidth = 100;
float BuildPlatformHeight = 100;
float GridSpacing = 10;
float DisplayScale = 5;


//End of "easy" modifications you can make...
//Naturally I encourage everyone to learn and
//alter the code that follows!

ArrayList Slice;
Mesh STLFile;
PrintWriter output;
float MeshHeight;
RawDXF pgDxf;

//Configuration File Object
//Hijacks the above variables
//We'll ditch 'em once this works.
Configuration MyConfig = new Configuration();


//Thread Objects
Runnable STLLoad = new STLLoadProc();
Runnable FileWrite = new FileWriteProc();
Runnable DXFWrite = new DXFWriteProc();
Thread DXFWriteThread;
Thread FileWriteThread, STLLoadThread;
boolean DXFWriteTrigger = false;
boolean FileWriteTrigger = false;
boolean STLLoadTrigger = false;
float DXFWriteFraction = 0;
float FileWriteFraction = 0;
float STLLoadFraction = 0;

//Flags
boolean STLLoadedFlag = false;
boolean FileWrittenFlag = false;


int AppWidth = int(BuildPlatformWidth*DisplayScale);
int AppHeight = int(BuildPlatformHeight*DisplayScale);

//GUI Page Select
int GUIPage = 0;

//Page 0 GUI Widgets
GUIButton STLLoadButton = new GUIButton(10,125,100,15, "Load STL");
GUIProgressBar STLLoadProgress = new GUIProgressBar(120,125,370,15);
GUIButton FileWriteButton = new GUIButton(10,150,100,15, "Write GCode");
GUIProgressBar FileWriteProgress = new GUIProgressBar(120,150,370,15);
GUIButton DXFWriteButton = new GUIButton(10,175,100,15, "Write DXF Slices");
GUIProgressBar DXFWriteProgress = new GUIProgressBar(120,175,370,15);
GUITextBox STLName = new GUITextBox(120,25,370,15,"sculpt_dragon.stl");
GUIFloatBox STLScale = new GUIFloatBox(120,50,100,15, "1.0");
GUIFloatBox STLXRotate = new GUIFloatBox(390,50,100,15, "0.0");

//AllPage GUI Widgets
GUIButton RightButton = new GUIButton(AppWidth-90,AppHeight-20,80,15, "Right");
GUIButton LeftButton = new GUIButton(10,AppHeight-20,80,15, "Left");


void setup(){
//  if(DXFExportMode != 0) size(AppWidth,AppHeight,P3D);
//  if(DXFExportMode == 0) size(AppWidth,AppHeight,JAVA2D);
  size(AppWidth,AppHeight,P2D);

  Slice = new ArrayList();
  
  if(DXFExportMode != 0) DXFWriteThread = new Thread(DXFWrite);
  if(DXFExportMode != 0) DXFWriteThread.start();
  FileWriteThread = new Thread(FileWrite);
  FileWriteThread.start();
  STLLoadThread = new Thread(STLLoad);
  STLLoadThread.start();

  //For initialization
  //~config.txt
  MyConfig.Load();
  STLScale.setFloat(MyConfig.PreScale);
  STLName.Text = MyConfig.FileName;
  STLXRotate.setFloat(MyConfig.XRotate);
  FlowRate = MyConfig.FlowRate;
  OperatingTemp = MyConfig.OperatingTemp;
  PrintHeadSpeed = MyConfig.PrintHeadSpeed;
  LayerThickness = MyConfig.LayerThickness;
  Sink = MyConfig.Sink;
  noLoop();
}

//This executes on Exit
//Autosave for ~config.txt
void stop()
{
  if(STLScale.Valid)MyConfig.PreScale=STLScale.getFloat();
  if(STLXRotate.Valid)MyConfig.XRotate=STLXRotate.getFloat();
  MyConfig.FileName=STLName.Text;
  MyConfig.FlowRate=FlowRate;
  MyConfig.OperatingTemp=OperatingTemp;  
  MyConfig.PrintHeadSpeed=PrintHeadSpeed;
  MyConfig.LayerThickness=LayerThickness;
  Sink = MyConfig.Sink;
  
  MyConfig.Save();
  super.stop();
}

void draw()
{
  background(0);
  stroke(0);
  strokeWeight(2);
  PFont font;
  font = loadFont("ArialMT-12.vlw");
  

  //GUI Pages

  //Interface Page
  if(GUIPage==0)
  {
    textAlign(CENTER);
    textFont(font);
    textMode(SCREEN);
    fill(255);
    text("GCODE Write",width/2,15);
    
    textAlign(LEFT);
    text("STL File Name",10,37);
    STLName.display();
    text("Scale Factor",10,62);
    STLScale.display();
    
    text("X-Rotation",300,62);
    STLXRotate.display();

    
    if(DXFExportMode != 0) DXFWriteProgress.update(DXFWriteFraction);
    if(DXFExportMode != 0) DXFWriteButton.display();
    if(DXFExportMode != 0) DXFWriteProgress.display();
    FileWriteProgress.update(FileWriteFraction);
    FileWriteButton.display();
    FileWriteProgress.display();
    STLLoadProgress.update(STLLoadFraction);
    STLLoadButton.display();
    STLLoadProgress.display();
  }



  //MeshMRI
  //Only relates to the final gcode in that
  //it shows you 2D sections of the mesh.
  if(GUIPage==1)
  {
    textAlign(CENTER);
    textFont(font);
    textMode(SCREEN);
    fill(255);
    text("MeshMRI",width/2,15);

    SSLine Intersection;
    Slice = new ArrayList();

    //Draw the grid
    stroke(80);
    strokeWeight(1);
    for(float px = 0; px<(BuildPlatformWidth*DisplayScale+1);px=px+GridSpacing*DisplayScale)line(px,0,px,BuildPlatformHeight*DisplayScale);
    for(float py = 0; py<(BuildPlatformHeight*DisplayScale+1);py=py+GridSpacing*DisplayScale)line(0,py,BuildPlatformWidth*DisplayScale,py);
    
    if(STLLoadedFlag)
    {
      for(int i = STLFile.Triangles.size()-1;i>=0;i--)
      {
        Triangle tri = (Triangle) STLFile.Triangles.get(i);
        Intersection = tri.GetZIntersect(MeshHeight*mouseX/width);
        if(Intersection!=null)Slice.add(Intersection);
      }
 
      //Draw the profile
      stroke(255);
      strokeWeight(2);
      for(int i = Slice.size()-1;i>=0;i--)
      {
        SSLine lin = (SSLine) Slice.get(i);
        SSLine newLine = new SSLine(lin.x1,lin.y1,lin.x2,lin.y2);
        //Translate into Display Coordinates
        newLine.Scale(DisplayScale);
        newLine.Rotate(PI);
        newLine.Translate(BuildPlatformWidth*DisplayScale/2,BuildPlatformHeight*DisplayScale/2);        
        line(newLine.x1,newLine.y1,newLine.x2,newLine.y2);
      }
    }
    else
    {
      text("STL File Not Loaded",width/2,height/2);
    }
  }
  if( GUIPage != 2) {
    //Always On Top, so last in order
    LeftButton.display();
    RightButton.display();
  }
}

//Save file on click
void mousePressed()
{
  if(DXFExportMode != 0) if((DXFWriteButton.over(mouseX,mouseY))&GUIPage==0)DXFWriteTrigger=true;
  if((FileWriteButton.over(mouseX,mouseY))&GUIPage==0)FileWriteTrigger=true;
  if((STLLoadButton.over(mouseX,mouseY))&GUIPage==0)STLLoadTrigger=true;
  if(GUIPage==0)STLName.checkFocus(mouseX,mouseY);
  if(GUIPage==0)STLScale.checkFocus(mouseX,mouseY);
  if(GUIPage==0)STLXRotate.checkFocus(mouseX,mouseY);
  if(GUIPage==0 && STLName.Focus) STLName.Text=selectInput();

  if(LeftButton.over(mouseX,mouseY))GUIPage--;
  if(RightButton.over(mouseX,mouseY))GUIPage++;
  if(GUIPage==3)GUIPage=0;
  if(GUIPage==-1)GUIPage=1;
  redraw();
}

void keyTyped()
{
  if(GUIPage==0)STLName.doKeystroke(key);
  if(GUIPage==0)STLScale.doKeystroke(key);
  if(GUIPage==0)STLXRotate.doKeystroke(key);  
  redraw();
}


//Convert the binary format of STL to floats.
float bin_to_float(byte b0, byte b1, byte b2, byte b3)
{
  int exponent, sign;
  float significand;
  float finalvalue=0;
  
  //fraction = b0 + b1<<8 + (b2 & 0x7F)<<16 + 1<<24;
  exponent = (b3 & 0x7F)*2 | (b2 & 0x80)>>7;
  sign = (b3&0x80)>>7;
  exponent = exponent-127;
  significand = 1 + (b2&0x7F)*pow(2,-7) + b1*pow(2,-15) + b0*pow(2,-23);  //throwing away precision for now...

  if(sign!=0)significand=-significand;
  finalvalue = significand*pow(2,exponent);

  return finalvalue;
}


//Display floats cleanly!
float CleanFloat(float Value)
{
  Value = Value * 1000;
  Value = round(Value);
  return Value / 1000;
}


class STLLoadProc implements Runnable{
  public void run()
  {
    while(true)
    {
      while(!STLLoadTrigger)delay(300);
      STLLoadTrigger = false;
      STLLoadFraction = 0.0;
      STLLoadProgress.message("STL Load May Take a Minute or more...");
      STLFile = new Mesh(STLName.Text);

      //Scale and locate the mesh
      //These will do nothing if these methods return NaN
      STLFile.Scale(STLScale.getFloat());
      STLFile.RotateX(STLXRotate.getFloat()*180/PI);
      //Put the mesh in the middle of the platform:
      STLFile.Translate(-STLFile.bx1,-STLFile.by1,-STLFile.bz1);
      STLFile.Translate(-STLFile.bx2/2,-STLFile.by2/2,0);
      STLFile.Translate(0,0,-LayerThickness);  
      STLFile.Translate(0,0,-Sink);
      MeshHeight=STLFile.bz2-STLFile.bz1;
      STLLoadFraction = 1.1;
      STLLoadedFlag = true;
      redraw();
    }
  }
}


class FileWriteProc implements Runnable{
  public void run(){
    while(true){
      while(!FileWriteTrigger)delay(300);
      FileWriteTrigger=false;//Only do this once per command.
      SSLine Intersection;
      SSLine lin;
      String GCodeFileName = selectOutput("Save G-Code to This File");
      if(GCodeFileName == null) {
        println("No file was selected; using STL File as G-Code file prefix.");
        GCodeFileName=STLName.Text+".gcode";
      }
      output = createWriter(GCodeFileName);

      //Header:
      output.println("G21");
      output.println("G90");
      output.println("M103");
      output.println("M105");
      output.println("M104 s"+OperatingTemp+".0");
      output.println("M109 s"+FlowRate+".0");
      output.println("M101");

      Slice ThisSlice;
      float Layers = STLFile.bz2/LayerThickness;
      for(float ZLevel = 0;ZLevel<(STLFile.bz2-LayerThickness);ZLevel=ZLevel+LayerThickness)
      {
        FileWriteFraction = (ZLevel/(STLFile.bz2-LayerThickness));
        ThisSlice = new Slice(STLFile,ZLevel);
        lin = (SSLine) ThisSlice.Lines.get(0);
        output.println("G1 X" + lin.x1 + " Y" + lin.y1 + " Z" + ZLevel + " F" + PrintHeadSpeed);
        for(int j = 0;j<ThisSlice.Lines.size();j++)
        {
          lin = (SSLine) ThisSlice.Lines.get(j);
          output.println("G1 X" + lin.x2 + " Y" + lin.y2 + " Z" + ZLevel + " F" + PrintHeadSpeed);
        }
      }
      output.flush();
      output.close();

      FileWriteFraction=1.5;
      print("\nFinished Slicing!  Bounding Box is:\n");
      print("X: " + CleanFloat(STLFile.bx1) + " - " + CleanFloat(STLFile.bx2) + "   ");
      print("Y: " + CleanFloat(STLFile.by1) + " - " + CleanFloat(STLFile.by2) + "   ");
      print("Z: " + CleanFloat(STLFile.bz1) + " - " + CleanFloat(STLFile.bz2) + "   ");
      if(STLFile.bz1<0)print("\n(Values below z=0 not exported.)");

      MeshHeight=STLFile.bz2-STLFile.bz1;
      STLLoadedFlag = true;
      redraw();
    }
  }
}


class DXFWriteProc implements Runnable{
  public void run(){
    while(true){
      while(!DXFWriteTrigger)delay(300);
      DXFWriteTrigger=false;//Only do this once per command.
      // GUIPage=2;
      SSLine Intersection;
      SSLine lin;
      
      String DXFSliceFilePrefix = selectOutput("Save Results to This File Path and Prefix");
      if(DXFSliceFilePrefix == null) {
        println("No file was selected; using STL File location as path+prefix.");
        DXFSliceFilePrefix=STLName.Text;
      }
      String DXFSliceFileName;
      int DXFSliceNum;
      
      String OpenSCADFileName = DXFSliceFilePrefix + "_" + LayerThickness + ".scad";
      
      output = createWriter(OpenSCADFileName);
      output.println("// OpenSCAD Wrapper for sliced "+STLName.Text+" DXF.\n");
      output.println("layerThickness="+LayerThickness+";");
      output.println("layerHeight="+LayerThickness+"/2;");
      output.println("minX=" + CleanFloat(STLFile.bx1) + ";\nmaxX=" + CleanFloat(STLFile.bx2) + ";");
      output.println("minY=" + CleanFloat(STLFile.by1) + ";\nmaxY=" + CleanFloat(STLFile.by2) + ";");
      output.println("minZ=" + CleanFloat(STLFile.bz1) + ";\nminZ=" + CleanFloat(STLFile.bz2) + ";\n");
      output.println("render_select=0; // render single slice");
      output.println("// render_select=1; // render all slices");
      output.println("\nmodule dxf_slice(index=0) {");
      
      Slice ThisSlice;
      // ArrayList PolyArray;
      float Layers = STLFile.bz2/LayerThickness;
      int renderWidth=width, renderHeight=height;
      int sliceCount=0;
      DXFSliceFileName = DXFSliceFilePrefix + "_" + LayerThickness + ".dxf";
      print("DXF Slice File Name: " + DXFSliceFileName + "\n");
      pgDxf=(RawDXF) createGraphics(round(BuildPlatformWidth),round(BuildPlatformHeight),DXF,DXFSliceFileName);
      beginRaw(pgDxf);
      for(float ZLevel = 0;ZLevel<(STLFile.bz2-LayerThickness);ZLevel=ZLevel+LayerThickness)
      {
        DXFSliceNum = round(ZLevel / LayerThickness);
        pgDxf.setLayer(DXFSliceNum);
        DXFWriteFraction = (ZLevel/(STLFile.bz2-LayerThickness));
        ThisSlice = new Slice(STLFile,ZLevel);
        // lin = (SSLine) ThisSlice.Lines.get(0);
	PathIterator pathIter=ThisSlice.SlicePath.getPathIterator(new AffineTransform());
	float[] newCoords={0.0,0.0};
	float[] prevCoords={0.0,0.0};
	int segType=pathIter.currentSegment(prevCoords);
	pathIter.next();
	while(!pathIter.isDone()) {
	  segType=pathIter.currentSegment(newCoords);
	  if(segType == PathIterator.SEG_LINETO ) {
	    // println("  SEG_LINETO: "+newCoords[0]+" "+newCoords[1]+"\n");
	    print(".");
	    pgDxf.line(prevCoords[0],prevCoords[1],newCoords[0],newCoords[1]);
	  } else if( segType==PathIterator.SEG_CLOSE) {
	    println("  Slice: "+DXFSliceNum+"  SEG_CLOSE: "+newCoords[0]+" "+newCoords[1]+"\n");
	    pgDxf.line(prevCoords[0],prevCoords[1],newCoords[0],newCoords[1]);
	  } else if(segType == PathIterator.SEG_MOVETO) {
	    println("  Slice: "+DXFSliceNum+"  SEG_MOVETO: "+newCoords[0]+" "+newCoords[1]+"\n");
	  } else {
	    println("  Slice: "+DXFSliceNum+"  segType: "+segType+"\n");
	  }
	  segType=pathIter.currentSegment(prevCoords);
	  pathIter.next();
	}
        output.println(" if(index>="+DXFSliceNum+"&&index<(1+"+DXFSliceNum+")) {");
        output.println("  echo(\"  Instantiating slice "+DXFSliceNum+".\");");
        output.println("  import_dxf(file=\"" + DXFSliceFileName + "\", layer=\""+DXFSliceNum+"\");\n" );
        output.println(" }");
        sliceCount++;
      }
      endRaw();
      output.println(" if(index>="+sliceCount+") {");
      output.println("  echo(\"ERROR: Out of index bounds.\");");
      output.println(" }");
      output.println("}");
      output.println("function get_dxf_slice_count() = "+sliceCount+";\n");
      output.println("render_slice=(get_dxf_slice_count()-1)*$t; // Use OpenSCAD Animation to step thru slices.\n");
      output.println("if(render_select==0) {");
      output.println("  dxf_slice(index=render_slice);");
      output.println("}\n");
      output.println("if(render_select==1) {");
      output.println("  for( i=[0:get_dxf_slice_count()-1] ) {");
      output.println("    translate([0,0,i*layerThickness])");
      output.println("      dxf_slice(index=i);");
      output.println("  }");
      output.println("}\n");

      output.flush();
      output.close();
      
      GUIPage=0;
      DXFWriteFraction=1.5;
      print("Finished Slicing!  Bounding Box is:\n");
      print("X: " + CleanFloat(STLFile.bx1) + " - " + CleanFloat(STLFile.bx2) + "   ");
      print("Y: " + CleanFloat(STLFile.by1) + " - " + CleanFloat(STLFile.by2) + "   ");
      print("Z: " + CleanFloat(STLFile.bz1) + " - " + CleanFloat(STLFile.bz2) + "   ");
      if(STLFile.bz1<0)print("\n(Values below z=0 not exported.)");

      if(OpenSCADTestMode==1) {
        OpenSCAD runOSCAD = new OpenSCAD();
        runOSCAD.setInput(OpenSCADFileName);
        runOSCAD.setOutput(DXF,OpenSCADFileName+".dxf");
        print("Running OpenSCAD Process:\n");
        print("   Exec Path: "+runOSCAD.getExecPath()+"\n");
        print("   Exec Args: "+runOSCAD.getExecArgs()+"\n");
        print("  Input File: "+runOSCAD.getInput()+"\n");
        if(runOSCAD.run()) {
          print("Run Finished!\n");
        } else {
          print("Run Error.\n");
        }
        // open(OpenSCADFileName);
      }

      MeshHeight=STLFile.bz2-STLFile.bz1;
      STLLoadedFlag = true;
      redraw();
    }
  }
}

