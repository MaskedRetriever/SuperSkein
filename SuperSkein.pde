//SuperSkein!
//
//SuperSkein is an open source mesh slicer.
//Note!  Only takes binary-coded STL.  ASCII
//STL just breaks it for now.

//Slicing Parameters-- someone should make
//a GUI menu at some point...
//Sorted here according to units

//"funny" dimensionality
float PrintHeadSpeed = 2000.0;

//Measured in millimeters
float LayerThickness = 0.3;
float Sink = 2;

//Dimensionless
float PreScale = 0.6;
//String FileName = "dense800ktris.stl";
String FileName = "sculpt_dragon.stl";

//Radians
float XRotate = 0;

//Display Properties
float BuildPlatformWidth = 100;
float BuildPlatformHeight = 100;
float GridSpacing = 10;
float DisplayScale = 5;



//End of "easy" modifications you can make...
//Naturally I encourage everyone to learn and
//alter the code that follows!
int t=0;
float tfloat=0;
float[] Tri = new float[9];
ArrayList Slice;
Mesh STLFile;
PrintWriter output;
float MeshHeight;


//Thread Objects
//Runnable FileLoad = new FileLoadProc();
Runnable FileWrite = new FileWriteProc();
Thread FileWriteThread, FileLoadThread;
boolean FileWriteTrigger = false;
boolean FileLoadTrigger = false;
float FileWriteFraction = 0;


int AppWidth = int(BuildPlatformWidth*DisplayScale);
int AppHeight = int(BuildPlatformHeight*DisplayScale);

//GUI Page Select
int GUIPage = 0;

//Page 0 GUI Widgets
GUIButton FileWriteButton = new GUIButton(10,20,100,15, "Write File");
GUIProgressBar FileWriteProgress = new GUIProgressBar(140,20,300,15);

//AllPage GUI Widgets
GUIButton RightButton = new GUIButton(AppWidth-90,AppHeight-20,80,15, "Right");
GUIButton LeftButton = new GUIButton(10,AppHeight-20,80,15, "Left");


void setup(){
  size(AppWidth,AppHeight);

  Slice = new ArrayList();
  
  FileWriteThread = new Thread(FileWrite);
  FileWriteThread.start();
  
  print("Loading STL...\n");
  //Load the .stl
  //Later we should totally make this runtime...
  STLFile = new Mesh(FileName);


  //Scale and locate the mesh
  STLFile.Scale(PreScale);
  STLFile.RotateX(XRotate);
  //Put the mesh in the middle of the platform:
  STLFile.Translate(-STLFile.bx1,-STLFile.by1,-STLFile.bz1);
  STLFile.Translate(-STLFile.bx2/2,-STLFile.by2/2,0);
  STLFile.Translate(0,0,-LayerThickness);  
  STLFile.Translate(0,0,-Sink);


  print("File Loaded, Slicing:\n");
  print("X: " + CleanFloat(STLFile.bx1) + " - " + CleanFloat(STLFile.bx2) + "   ");
  print("Y: " + CleanFloat(STLFile.by1) + " - " + CleanFloat(STLFile.by2) + "   ");
  print("Z: " + CleanFloat(STLFile.bz1) + " - " + CleanFloat(STLFile.bz2) + "   \n");
  //Spit GCODE!
  //Match viewport scale to 1cm per gridline
  //STLFile.Scale(DisplayScale);
  //STLFile.Translate(BuildPlatformWidth*DisplayScale/2,BuildPlatformHeight*DisplayScale/2,-STLFile.bz1);
  //STLFile.Translate(-STLFile.bx1,-STLFile.by1,-STLFile.bz1);

  MeshHeight=STLFile.bz2-STLFile.bz1;

}

void draw()
{
  background(0);
  stroke(0);
  strokeWeight(2);

  
  //Interface Page
  if(GUIPage==0)
  {
    FileWriteProgress.update(FileWriteFraction);
    FileWriteButton.display();
    FileWriteProgress.display();
  }


  //MeshMRI
  //Only relates to the final gcode in that
  //it shows you 2D sections of the mesh.
  if(GUIPage==1)
  {
    Line2D Intersection;
    Slice = new ArrayList();
    
    
    for(int i = STLFile.Triangles.size()-1;i>=0;i--)
    {
    
      Triangle tri = (Triangle) STLFile.Triangles.get(i);
      Intersection = tri.GetZIntersect(MeshHeight*mouseX/width);
      if(Intersection!=null)Slice.add(Intersection);
      //if(Intersection!=null)print(Intersection.x1 + " \n");
    }


    //Draw the grid
    stroke(80);
    strokeWeight(1);
    for(float px = 0; px<(BuildPlatformWidth*DisplayScale+1);px=px+GridSpacing*DisplayScale)line(px,0,px,BuildPlatformHeight*DisplayScale);
    for(float py = 0; py<(BuildPlatformHeight*DisplayScale+1);py=py+GridSpacing*DisplayScale)line(0,py,BuildPlatformWidth*DisplayScale,py);
  

    //Draw the profile
    stroke(255);
    strokeWeight(2);
    for(int i = Slice.size()-1;i>=0;i--)
    {
      Line2D lin = (Line2D) Slice.get(i);
      Line2D newLine = new Line2D(lin.x1,lin.y1,lin.x2,lin.y2);
      //lin.Scale(15);
      newLine.Scale(-DisplayScale);
      newLine.Translate(BuildPlatformWidth*DisplayScale/2,BuildPlatformHeight*DisplayScale/2);
      line(newLine.x1,newLine.y1,newLine.x2,newLine.y2);
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
  if(LeftButton.over(mouseX,mouseY))GUIPage--;
  if(RightButton.over(mouseX,mouseY))GUIPage++;
  if(GUIPage==2)GUIPage=0;
  if(GUIPage==-1)GUIPage=1;
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



//Print a status bar
void TextStatusBar(float Percent, int Width)
{
  print("[");
  int Stars = int(Percent*Width)+1;
  int Dashes = Width-Stars;
  for(int i = 0; i<Stars; i++)print("X");
  for(int i = 0; i<Dashes; i++)print(".");
  print("]");
}


class FileWriteProc implements Runnable{
  public void run(){
    while(true){
      while(!FileWriteTrigger);
      FileWriteTrigger=false;//Only do this once per command.
        Line2D Intersection;
  Line2D lin;
  output = createWriter("output.gcode");


  //Scale and locate the mesh
  //STLFile.Scale(1/DisplayScale);
  //Put the mesh in the middle of the platform:
//  STLFile.Translate(-STLFile.bx1,-STLFile.by1,-STLFile.bz1);
//  STLFile.Translate(-STLFile.bx2/2,-STLFile.by2/2,0);
//  STLFile.Translate(0,0,-LayerThickness);  
//  STLFile.Translate(0,0,-Sink);


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

  //THEN scale to fit the screen
//  if((STLFile.bx2-STLFile.bx1)>(STLFile.by2-STLFile.by1))
//  {
//    STLFile.Scale(width/(STLFile.bx2-STLFile.bx1));
//  }
//  else
//  {
//    STLFile.Scale(height/(STLFile.by2-STLFile.by1));
//  }
//  STLFile.Scale(DisplayScale);
//  STLFile.Translate(BuildPlatformWidth*DisplayScale/2,BuildPlatformHeight*DisplayScale/2,-STLFile.bz1);
  //STLFile.Translate(-STLFile.bx1,-STLFile.by1,-STLFile.bz1);
  MeshHeight=STLFile.bz2-STLFile.bz1;

  

    }
  }
}

