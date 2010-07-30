//SuperSkein!
//
//SuperSkein is an open source mesh slicer.
//Note!  Only takes binary-coded STL.  ASCII
//STL just breaks it for now.

//Slicing Parameters-- someone should make
//a GUI menu at some point...
//Obviously not as many of them now...
float PrintHeadSpeed = 2000.0;
float LayerThickness = 0.3;
String FileName = "sculpt_dragon.stl";


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


void setup(){
  size(640,360);

  Slice = new ArrayList();
  print("Loading STL...\n");
  //Load the .stl
  //Later we should totally make this runtime...
  STLFile = new Mesh(FileName);
  //Scale and locate the mesh
  //STLFile.Scale(10);
  
  //Put the mesh on the platform:
  STLFile.Translate(0,0,-STLFile.bz1);
  STLFile.Translate(0,0,-LayerThickness);  
  print("File Loaded, Slicing:\n");

//Spit GCODE!
Line2D Intersection;
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
  ThisSlice = new Slice(STLFile,ZLevel);
  print("Slicing: ");
  TextStatusBar(ZLevel/STLFile.bz2,40);
  print("\n");
    for(int j = ThisSlice.Lines.size()-1;j>=0;j--)
    {
      Line2D lin = (Line2D) ThisSlice.Lines.get(j);
      output.println("G1 X" + lin.x1 + " Y" + lin.y1 + " Z" + ZLevel + " F" + PrintHeadSpeed);
    }
}
output.flush();
output.close();

print("Finished Slicing!  Bounding Box is:\n");
print("X: " + CleanFloat(STLFile.bx1) + " - " + CleanFloat(STLFile.bx2) + "   ");
print("Y: " + CleanFloat(STLFile.by1) + " - " + CleanFloat(STLFile.by2) + "   ");
print("Z: " + CleanFloat(STLFile.bz1) + " - " + CleanFloat(STLFile.bz2) + "   ");


  //THEN scale to fit
  if((STLFile.bx2-STLFile.bx1)>(STLFile.by2-STLFile.by1))
  {
    STLFile.Scale(width/(STLFile.bx2-STLFile.bx1));
  }
  else
  {
    STLFile.Scale(height/(STLFile.by2-STLFile.by1));
  }
  STLFile.Translate(-STLFile.bx1,-STLFile.by1,-STLFile.bz1);
  MeshHeight=STLFile.bz2-STLFile.bz1;

}

void draw()
{
  background(0);
  //noStroke();
 
  //background(0);
  stroke(0);
  strokeWeight(2);

  //Generate a Slice
  Line2D Intersection;
  Slice = new ArrayList();
  for(int i = STLFile.Triangles.size()-1;i>=0;i--)
  {
    
    Triangle tri = (Triangle) STLFile.Triangles.get(i);
    Intersection = tri.GetZIntersect(MeshHeight*mouseX/width);
    if(Intersection!=null)Slice.add(Intersection);
    //if(Intersection!=null)print(Intersection.x1 + " \n");
  }

  for(int i = Slice.size()-1;i>=0;i--)
  {
    stroke(255);
    Line2D lin = (Line2D) Slice.get(i);
    //lin.Scale(15);
    line(lin.x1,lin.y1,lin.x2,lin.y2);
  }

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

