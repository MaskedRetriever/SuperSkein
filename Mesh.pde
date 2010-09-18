// Mesh Class

class Mesh {
  ArrayList Triangles;
  float bx1,by1,bz1,bx2,by2,bz2; //bounding box
  boolean Valid;

  float Sink;

  //Mesh Loading routine
  Mesh(String FileName)
  {
    Valid = false;
    
    println ("loading file " + FileName + "...");
    Triangles = new ArrayList();
    Sink=0;

    if (LoadTextMesh (FileName))
    {
      Valid = true;
      CalculateBoundingBox();
    }
    else if (LoadBinaryMesh (FileName))
    {
      Valid = true;
      CalculateBoundingBox();
    }
  }

  private boolean LoadBinaryMesh (String FileName)
  {
    try
    {
      byte b[] = loadBytes(FileName);
      float[] Tri = new float[9];
      //Skip the header
      int offs = 84;
      //Read each triangle out
      while(offs<b.length){
        offs = offs + 12; //skip the normals entirely!
        for(int i = 0; i<9; i++)
        {
          Tri[i]=bin_to_float(b[offs],b[offs+1],b[offs+2],b[offs+3]);
          offs=offs+4;
        }
        offs=offs+2;//Skip the attribute bytes
        Triangles.add(new Triangle(Tri[0],Tri[1],Tri[2],Tri[3],Tri[4],Tri[5],Tri[6],Tri[7],Tri[8]));
      }
    }
    catch (Exception e)
    {
      println ("Unable to load binary STL");
      return false;
    }

    return true;
  }

  private boolean LoadTextMesh (String path)
  {
    // text format:

    // solid ascii
    //   facet normal -2.242146e-006 -8.944270e-001 -4.472139e-001
    //     outer loop
    //       vertex   5.000000e+001 3.829179e+001 7.236046e+000
    //       vertex   4.048944e+001 3.690984e+001 1.000000e+001
    //       vertex   4.412215e+001 4.190984e+001 -1.963632e-006
    //     endloop
    //   endfacet
    //   facet normal -8.506515e-001 -2.763928e-001 -4.472125e-001
    //     outer loop
    // .
    // .
    //   endfacet
    // endsolid

    BufferedReader reader;
    String buf;

    try
    {
      reader = createReader (path);

      buf = reader.readLine();
      if (buf.indexOf ("solid") != 0)
      {
        // doesn't appear to be a text stl..
        return false;
      }
    }
    catch (RuntimeException ex)
    {
      // this is (more than..) a bit stupid. java complains if you ask it to open
      // abc.stl when the file name is ABC.stl. figuring out and using then actual
      // path somewhere above would be good..

      println ("Unable to read from buffered reader. Check to make sure you gave the EXACT pathname (case matters)");
      return false;
    }
    catch (Exception e)
    {
      // file doesn't exist or something.. likely won't fail on binary stl
      println ("unable to read from buffered reader..");
      return false;
    }

    try
    {
      while (true)
      {
        buf = reader.readLine();
        if (buf == null || buf.indexOf ("endsolid") == 0)
        {
          // end of file or last valid line.. good stuff
          break;
        }
        
        if (buf.indexOf ("facet normal") == -1)
        {
          // sanity check.. 
          return false;
        }
  
        buf = reader.readLine();  // "    outer loop" 

        String[] floats;
        int offset;

        // read in the first triangle.. "vertex " followed by 3 floats.. the 
        // regex string split sometimes returns an extra leading entry with
        // nothing in it (5 elements in the 'floats' array) and sometimes 
        // doesn't (4 elements) so check the length and offset by 1 if needed
        floats = reader.readLine().split("[\\s,;]+");
        offset = floats.length == 5 ? 1 : 0;
        float x1 = Float.parseFloat (floats[1 + offset]);
        float y1 = Float.parseFloat (floats[2 + offset]);
        float z1 = Float.parseFloat (floats[3 + offset]);

        // 2nd triangle
        floats = reader.readLine().split("[\\s,;]+");
        offset = floats.length == 5 ? 1 : 0;
        float x2 = Float.parseFloat (floats[1 + offset]);
        float y2 = Float.parseFloat (floats[2 + offset]);
        float z2 = Float.parseFloat (floats[3 + offset]);

        // 3rdd triangle
        floats = reader.readLine().split("[\\s,;]+");
        offset = floats.length == 5 ? 1 : 0;
        float x3 = Float.parseFloat (floats[1 + offset]);
        float y3 = Float.parseFloat (floats[2 + offset]);
        float z3 = Float.parseFloat (floats[3 + offset]);

        Triangles.add (new Triangle (x1, y1, z1, x2, y2, z2, x3, y3, z3));

        reader.readLine(); // "   endloop"
        reader.readLine(); // "  endfacet"
      }
    }
    catch (Exception e) 
    {
      return false;
    }

    return true;
  }

  void Scale(float Factor)
  {
    if(Float.isNaN(Factor))return;
    for(int i = Triangles.size()-1;i>=0;i--)
    {
      Triangle tri = (Triangle) Triangles.get(i);
      tri.Scale(Factor);
    }
    CalculateBoundingBox();
  }

  void Translate(float tx, float ty, float tz)
  {
    for(int i = Triangles.size()-1;i>=0;i--)
    {
      Triangle tri = (Triangle) Triangles.get(i);
      tri.Translate(tx,ty,tz);
    }
    CalculateBoundingBox();
  }


  void RotateX(float Angle)
  {
    if(Float.isNaN(Angle))return;
    for(int i = Triangles.size()-1;i>=0;i--)
    {
      Triangle tri = (Triangle) Triangles.get(i);
      tri.RotateX(Angle);
    }
    CalculateBoundingBox();
  } 

  void CalculateBoundingBox()
  {
      bx1 = 10000;
      bx2 = -10000;
      by1 = 10000;
      by2 = -10000;
      bz1 = 10000;
      bz2 = -10000;
      for(int i = Triangles.size()-1;i>=0;i--)
    {

      Triangle tri = (Triangle) Triangles.get(i);
      if(tri.x1<bx1)bx1=tri.x1;
      if(tri.x2<bx1)bx1=tri.x2;
      if(tri.x3<bx1)bx1=tri.x3;
      if(tri.x1>bx2)bx2=tri.x1;
      if(tri.x2>bx2)bx2=tri.x2;
      if(tri.x3>bx2)bx2=tri.x3;
      if(tri.y1<by1)by1=tri.y1;
      if(tri.y2<by1)by1=tri.y2;
      if(tri.y3<by1)by1=tri.y3;
      if(tri.y1>by2)by2=tri.y1;
      if(tri.y2>by2)by2=tri.y2;
      if(tri.y3>by2)by2=tri.y3;
      if(tri.z1<bz1)bz1=tri.z1;
      if(tri.z2<bz1)bz1=tri.z2;
      if(tri.z3<bz1)bz1=tri.z3;
      if(tri.z1>bz2)bz2=tri.z1;
      if(tri.z2>bz2)bz2=tri.z2;
      if(tri.z3>bz2)bz2=tri.z3;
    }    
  }
}  

