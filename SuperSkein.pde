//SuperSkein!
//
//SuperSkein is an open source mesh slicer.
//Note!  Only takes binary-coded STL.  ASCII
//STL just breaks it for now.

//Slicing Parameters-- someone should make
//a GUI menu at some point...
//Sorted here according to units


//Dimensionless
float PreScale = 1;
//String FileName = "dense800ktris.stl";
String FileName = "sculpt_dragon.stl";

//Radians
float XRotate = 0;



//Non-GUI-Reachable:

//"funny" dimensionality
float PrintHeadSpeed = 2000.0;

//Measured in millimeters
float LayerThickness = 0.3;
float Sink = 2;

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


//Thread Objects
Runnable STLLoad = new STLLoadProc();
Runnable FileWrite = new FileWriteProc();
Thread FileWriteThread, STLLoadThread;
boolean FileWriteTrigger = false;
boolean STLLoadTrigger = false;
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
GUITextBox STLName = new GUITextBox(120,25,370,15,"sculpt_dragon.stl");
GUITextBox STLScale = new GUITextBox(120,50,100,15, "1.0");
GUITextBox STLXRotate = new GUITextBox(390,50,100,15, "0.0");

//AllPage GUI Widgets
GUIButton RightButton = new GUIButton(AppWidth-90,AppHeight-20,80,15, "Right");
GUIButton LeftButton = new GUIButton(10,AppHeight-20,80,15, "Left");


void setup(){
  size(AppWidth,AppHeight,JAVA2D);
  

  Slice = new ArrayList();
  
  FileWriteThread = new Thread(FileWrite);
  FileWriteThread.start();
  STLLoadThread = new Thread(STLLoad);
  STLLoadThread.start();

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
    fill(255);
    text("GCODE Write",width/2,15);
    
    textAlign(LEFT);
    text("STL File Name",10,37);
    STLName.display();
    text("Scale Factor",10,62);
    STLScale.display();
    
    text("X-Rotation",300,62);
    STLXRotate.display();
    
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
    fill(255);
    text("MeshMRI",width/2,15);

    Line2D Intersection;
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
        Line2D lin = (Line2D) Slice.get(i);
        Line2D newLine = new Line2D(lin.x1,lin.y1,lin.x2,lin.y2);
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
  //Always On Top, so last in order
  LeftButton.display();
  RightButton.display();
}

//Save file on click
void mousePressed()
{
  if((FileWriteButton.over(mouseX,mouseY))&GUIPage==0)FileWriteTrigger=true;
  if((STLLoadButton.over(mouseX,mouseY))&GUIPage==0)STLLoadTrigger=true;
  if(GUIPage==0)STLName.checkFocus(mouseX,mouseY);
  if(GUIPage==0)STLScale.checkFocus(mouseX,mouseY);
  if(GUIPage==0)STLXRotate.checkFocus(mouseX,mouseY);

  if(LeftButton.over(mouseX,mouseY))GUIPage--;
  if(RightButton.over(mouseX,mouseY))GUIPage++;
  if(GUIPage==2)GUIPage=0;
  if(GUIPage==-1)GUIPage=1;
}

void keyTyped()
{
  if(GUIPage==0)STLName.doKeystroke(key);
  if(GUIPage==0)STLScale.doKeystroke(key);
  if(GUIPage==0)STLXRotate.doKeystroke(key);
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
      while(!STLLoadTrigger);
      STLLoadTrigger = false;
      STLLoadFraction = 0.0;
      STLLoadProgress.message("STL Load May Take a Minute or more...");
      STLFile = new Mesh(STLName.Text);

      //Scale and locate the mesh
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
    }
  }
}



class FileWriteProc implements Runnable{
  public void run(){
    while(true){
      while(!FileWriteTrigger);
      FileWriteTrigger=false;//Only do this once per command.
      Line2D Intersection;
      Line2D lin;
      output = createWriter("output.gcode");

      //Header:
      output.println("G21");
      output.println("G90");
      output.println("M103");
      output.println("M105");
      output.println("M104 s220.0");
      output.println("M109 s110.0");
      output.println("M101");

      Slice ThisSlice;
      float Layers = STLFile.bz2/LayerThickness;
      for(float ZLevel = 0;ZLevel<(STLFile.bz2-LayerThickness);ZLevel=ZLevel+LayerThickness)
      {
        FileWriteFraction = (ZLevel/(STLFile.bz2-LayerThickness));
        ThisSlice = new Slice(STLFile,ZLevel);
        lin = (Line2D) ThisSlice.Lines.get(0);
        output.println("G1 X" + lin.x1 + " Y" + lin.y1 + " Z" + ZLevel + " F" + PrintHeadSpeed);
        for(int j = 0;j<ThisSlice.Lines.size();j++)
        {
          lin = (Line2D) ThisSlice.Lines.get(j);
          output.println("G1 X" + lin.x2 + " Y" + lin.y2 + " Z" + ZLevel + " F" + PrintHeadSpeed);
        }
      }
      output.flush();
      output.close();

      FileWriteFraction=1.5;
      print("Finished Slicing!  Bounding Box is:\n");
      print("X: " + CleanFloat(STLFile.bx1) + " - " + CleanFloat(STLFile.bx2) + "   ");
      print("Y: " + CleanFloat(STLFile.by1) + " - " + CleanFloat(STLFile.by2) + "   ");
      print("Z: " + CleanFloat(STLFile.bz1) + " - " + CleanFloat(STLFile.bz2) + "   ");
      if(STLFile.bz1<0)print("\n(Values below z=0 not exported.)");

      MeshHeight=STLFile.bz2-STLFile.bz1;
      STLLoadedFlag = true;
    }
  }
}

