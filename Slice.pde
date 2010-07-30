// Slice Class
//
class Slice {
  
  ArrayList Lines;

  //Right now this is all in the constructor.
  //It might make more sense to split these
  //out but that's a pretty minor difference
  //at the moment.  
  Slice(Mesh InMesh, float ZLevel) {
    
    ArrayList UnsortedLines;    
    Line2D Intersection;
    UnsortedLines = new ArrayList();
    for(int i = InMesh.Triangles.size()-1;i>=0;i--)
    {
      Triangle tri = (Triangle) InMesh.Triangles.get(i);
      Intersection = tri.GetZIntersect(ZLevel);
      if(Intersection!=null)UnsortedLines.add(Intersection);
    }
    
    
    if(UnsortedLines==null)return;
        
    //Slice Sort: arrange the line segments so that
    //each segment leads to the nearest available
    //segment.  This is accomplished by using two
    //arraylists of lines, and at each step moving
    //the nearest available line segment from the
    //unsorted pile to the next slot in the sorted pile.
    Lines = new ArrayList();
    Lines.add(UnsortedLines.get(0));
    int FinalSize = UnsortedLines.size();
    UnsortedLines.remove(0);

    //ratchets for distance
    //dflipped exists to catch flipped lines
    float d,min_d,dflipped,min_dflipped;
    min_d = 10000;
    min_dflipped = 10000;

    int iNextLine;
    
    //while(Lines.size()<FinalSize)
    while(UnsortedLines.size()>0)
    {
      Line2D CLine = (Line2D) Lines.get(Lines.size()-1);//Get last
      iNextLine = (Lines.size()-1);
      min_d = 10000;
      min_dflipped = 10000;
      for(int i = UnsortedLines.size()-1;i>=0;i--)
      {
        Line2D LineCandidate = (Line2D) UnsortedLines.get(i);
        d = pow((LineCandidate.x1-CLine.x2),2) + pow((LineCandidate.y1-CLine.y2),2);
        dflipped = pow((LineCandidate.x1-CLine.x1),2) + pow((LineCandidate.y1-CLine.y1),2);
          
        if(d<min_d)
        {
          iNextLine=i;
          min_d = d;
        } 
        if(dflipped<min_dflipped)
        {
          iNextLine=i;
          min_dflipped = dflipped;
        }
 
      }

      Line2D LineToMove = (Line2D) UnsortedLines.get(iNextLine);
      //if(min_dflipped>min_d)LineToMove.Flip();
      Lines.add(LineToMove);
      UnsortedLines.remove(iNextLine);
    }
  }
  



}  
